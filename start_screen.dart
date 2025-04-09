import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'newpostscreen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _initializeApp(BuildContext context) {
    // Basic app initialization logic
    debugPrint('App initialized!');

    // Navigate to home screen after initialization
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NewPostScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // You can add other content here that fills the screen
          const Center(
            child: Text(
              '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Positioned button at the bottom
          Positioned(
            bottom: 40, // Adjust this value to change distance from bottom
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _initializeApp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Start'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}