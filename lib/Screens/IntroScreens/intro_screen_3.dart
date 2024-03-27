import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa2d19f),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "images/imagesharing.json",
              height: 250,
              width: 250,
            ),
            const SizedBox(height: 32),
            const Text(
              "Intelligent Photo Sharing",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "ExploreEase intelligently organizes user photos in such a way that users upload all the images which is detected through faces and separate them according to user profile.",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              "Discover the magic of intelligent photo management with ExploreEase.",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
