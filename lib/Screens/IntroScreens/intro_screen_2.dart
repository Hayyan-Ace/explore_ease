import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFa2d19f),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "images/chat.json",
              height: 250,
              width: 250,
            ),
            SizedBox(height: 32),
            Text(
              "Group Chats",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "The platform fosters communication among travelers through features like group chats and dedicated tour groups, enhancing networking and interaction during journeys.",
              style: TextStyle(
                color: Color(0xFF172614),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text(
                "Immerse yourself in the world of seamless group communication with ExploreEase.",
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
