import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

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
              "images/tourTracking.json",
              height: 250,
              width: 250,
            ),
            const SizedBox(height: 32),
            const Text(
              "Live Tour Tracking",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "enable real-time tracking of tour groups and individual travelers during their journeys.",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              "Embark on a journey of real-time adventure with ExploreEase.",
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
