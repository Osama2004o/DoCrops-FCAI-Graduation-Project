import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/shared_widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // State Variables
  bool _isLoading = true;
  String _errorMessage = "";

  // Weather Data
  String _cityName = "Locating...";
  double _temperature = 0;
  double _windSpeed = 0;
  int _humidity = 0;
  int _weatherCode = 0; // WMO code from Open-Meteo
  String _formattedDate = "";

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat('EEEE, d MMM').format(DateTime.now());
    _initWeather();
  }

  Future<void> _initWeather() async {
    try {
      // 1. Get Permission & Location
      Position position = await _determinePosition();

      // 2. Get City Name (Reverse Geocoding)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          setState(() {
            _cityName = placemarks.first.locality ?? "Unknown City";
          });
        }
      } catch (e) {
        // If geocoding fails, just show coordinates
        _cityName =
            "${position.latitude.toStringAsFixed(1)}, ${position.longitude.toStringAsFixed(1)}";
      }

      // 3. Fetch Weather Data (Open-Meteo API)
      await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS is on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Location services are disabled. Please turn on GPS.',
      );
    }

    // Check Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    // API URL for Open-Meteo (Updated to Celsius and km/h)
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=celsius&wind_speed_unit=kmh',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current'];

      setState(() {
        _temperature = current['temperature_2m'];
        _humidity = current['relative_humidity_2m'];
        _windSpeed = current['wind_speed_10m'];
        _weatherCode = current['weather_code'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Helper to get description based on WMO code
  String _getWeatherDescription(int code) {
    if (code == 0) return "Clear sky";
    if (code >= 1 && code <= 3) return "Partly cloudy";
    if (code >= 45 && code <= 48) return "Foggy";
    if (code >= 51 && code <= 67) return "Rainy";
    if (code >= 95) return "Thunderstorms";
    return "Overcast";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // --- Main Weather Card ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formattedDate,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      "${_temperature.round()}°C", // Changed to C
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _getWeatherDescription(_weatherCode),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WeatherDetail(
                      icon: Icons.air,
                      label: "Wind: $_windSpeed km/h",
                    ), // Changed to km/h
                    WeatherDetail(
                      icon: Icons.water_drop,
                      label: "Hum: $_humidity%",
                    ),
                    const WeatherDetail(icon: Icons.wb_sunny, label: "UV: Mod"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Recommendations Section ---
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Planting Recommendations",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getRecommendations(_temperature),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Avoid Planting",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getAvoidList(_temperature),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers for Dynamic Crops (Using Celsius Thresholds) ---
  List<Widget> _getRecommendations(double temp) {
    // 24°C is roughly 75°F
    if (temp > 24) {
      return const [
        CropTag(text: "Tomatoes", isGood: true),
        CropTag(text: "Peppers", isGood: true),
        CropTag(text: "Corn", isGood: true),
        CropTag(text: "Okra", isGood: true),
      ];
    } else {
      return const [
        CropTag(text: "Lettuce", isGood: true),
        CropTag(text: "Spinach", isGood: true),
        CropTag(text: "Kale", isGood: true),
        CropTag(text: "Carrots", isGood: true),
      ];
    }
  }

  List<Widget> _getAvoidList(double temp) {
    if (temp > 24) {
      return const [
        CropTag(text: "Lettuce", isGood: false),
        CropTag(text: "Spinach", isGood: false),
      ];
    } else {
      return const [
        CropTag(text: "Tomatoes", isGood: false),
        CropTag(text: "Watermelon", isGood: false),
      ];
    }
  }
}
