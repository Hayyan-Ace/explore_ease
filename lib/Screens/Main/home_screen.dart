import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/LargeBoldText.dart';
import 'package:travel_ease_fyp/Widgets/firestore_slideshow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          ),),
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
