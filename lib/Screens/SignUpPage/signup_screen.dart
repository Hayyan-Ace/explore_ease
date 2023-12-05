import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:fluttertoast/fluttertoast.dart";
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Controllers/signup_controller.dart';
import 'package:travel_ease_fyp/Screens/LoginPage/login_screen.dart';

import 'package:travel_ease_fyp/Screens/Main/main_page.dart';

import '../../Models/User/user_model.dart';
import '../../Services/AuthentactionRepository/signup_service.dart';
import '../intro_screens/welcome.dart';


class SignUpScreen extends StatelessWidget {
  bool? isEmailVerified;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());


    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => SignUpController.instance.registerUser(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  _userNameController.text.trim()),

              child: const Text('Sign Up'),
        ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have an account? Log in here'),
            ),
          ],
        ),
      ),
    );
  }
}
