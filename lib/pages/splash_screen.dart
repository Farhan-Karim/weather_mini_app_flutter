import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Navigate to HomePage after a delay
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-bg.png',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              strokeWidth: 8.0, // Thick circle
              color: Colors.blueAccent, // Accent color for the progress
              backgroundColor:
                  Colors.grey[300], // Light grey background for contrast
            ) // Optional loading indicator
          ],
        ),
      ),
    );
  }
}
