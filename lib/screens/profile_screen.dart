import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color.fromARGB(255, 55, 86, 56),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "User",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("Plant Enthusiast", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: const [
              StatCard(icon: Icons.grass, count: "12", label: "Plants"),
              StatCard(icon: Icons.water_drop, count: "5", label: "Need Water"),
              StatCard(icon: Icons.bug_report, count: "2", label: "Issues"),
              StatCard(
                icon: Icons.calendar_today,
                count: "3",
                label: "Tasks Today",
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plant List
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "My Plants",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const PlantItem(
            name: "Monstera Deliciosa",
            subtitle: "Last watered: 2 days ago",
            color: Color(0xFF4CAF50),
            icon: Icons.grass,
          ),
          const PlantItem(
            name: "Snake Plant",
            subtitle: "Needs fertilizer",
            color: Color(0xFF8BC34A),
            icon: Icons.spa,
          ),
          const PlantItem(
            name: "Fern",
            subtitle: "Water today",
            color: Colors.orange,
            icon: Icons.local_florist,
          ),
        ],
      ),
    );
  }
}
