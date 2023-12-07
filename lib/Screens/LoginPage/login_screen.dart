import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Screens/Main/main_page.dart';
import '../../Controllers/login_controller.dart';
import '../SignUpPage/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF172614),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFa2d19f), Color(0xFFa2d19f)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16), // Added space
            Text(
              'ExploreEase',
              style: TextStyle(
                fontSize: 40, // Increased font size
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: 'YourCursiveFont', // Replace with your cursive font
              ),
            ),
            SizedBox(height: 50), // Added space
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Color(0xFF172614)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF172614)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF172614), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                labelStyle: TextStyle(color: Color(0xFF172614)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF172614)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF172614), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => LoginController.instance.loginUser(_emailController.text.trim(), _passwordController.text.trim()),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF172614),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              style: TextButton.styleFrom(
                primary: Color(0xFF172614),
              ),
              child: Text('Don\'t have an account? Sign up here'),
            ),
          ],
        ),
      ),
    );
  }
}
