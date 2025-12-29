import 'dart:io'; // Needed to handle File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // The package we just added

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = false;
  bool _showResults = false;
  File? _selectedImage; // Variable to hold the image file

  final ImagePicker _picker = ImagePicker(); // The camera tool

  // Function to open Camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path); // Save the image to our variable
        _showResults = false; // Reset results until they click "Analyze"
      });
      // Optional: Auto-analyze after taking photo?
      // _analyzePlant();
    }
  }

  // Function to open Gallery
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showResults = false;
      });
    }
  }

  void _analyzePlant() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take a photo first!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = false;
    });

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 20),
            Text("Analyzing your plant...", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Plant Analysis",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Take a photo of your plant to identify any issues",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // --- IMAGE PREVIEW AREA ---
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!), // Show the photo
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedImage == null
                ? const Icon(Icons.camera_alt, size: 80, color: Colors.grey)
                : null, // Hide icon if image exists
          ),
          const SizedBox(height: 20),

          // --- BUTTONS ---
          // If we haven't taken a photo yet, show Camera/Gallery buttons
          if (!_showResults) ...[
            ElevatedButton.icon(
              onPressed: _takePhoto, // Calls the camera function
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Take Photo",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickFromGallery, // Calls the gallery function
              icon: const Icon(Icons.folder_open, color: Color(0xFFFF9800)),
              label: const Text(
                "Choose from Gallery",
                style: TextStyle(color: Color(0xFFFF9800)),
              ),
            ),
          ],

          // If we have an image but no results yet, show "Analyze" button
          if (_selectedImage != null && !_showResults) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _analyzePlant,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Analyze This Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          // --- RESULTS SECTION (Same as before) ---
          if (_showResults) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Diagnosis",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Medium Severity",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your plant is showing signs of powdery mildew, a common fungal disease.",
                  ),
                  const Divider(height: 30),
                  const Text(
                    "Recommended Treatment",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "1. Remove affected leaves carefully\n2. Apply neem oil solution\n3. Improve air circulation",
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _showResults = false;
                      });
                    },
                    child: const Text("Scan Another Plant"),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
