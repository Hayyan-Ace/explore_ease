import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/LargeBoldText.dart';
import 'package:travel_ease_fyp/Widgets/firestore_slideshow.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        // You can customize the AppBar further if needed
      ),
      body: Column(
        children: [
          Expanded(
            child: SlideshowScreen(),
          ),
        ],
      ),
    );
  }
}
