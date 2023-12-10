import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';
import 'package:travel_ease_fyp/Screens/LoginPage/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();


  late Color myColor;


  @override
  Widget build(BuildContext context) {
    myColor = const Color(0xFFa2d19f);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              TextField(
                controller: _cnicController,
                decoration: InputDecoration(labelText: 'CNIC (13 digits)'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneNoController,
                decoration: InputDecoration(
                  labelText: 'Phone No',
                  prefixText: '+92 ',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 20,
                  shadowColor: myColor,
                  backgroundColor: myColor.withOpacity(0.9),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () => _registerUser(),
                child: const Text('Sign Up', style: TextStyle(color: Colors.black87)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Log in here',style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    // Validate CNIC (13 digits)
    if (_cnicController.text.trim().length != 13) {
      showToast("Invalid CNIC. It must be 13 digits.");
      return;
    }

    // Validate phone number (10 digits after the prefix)
    if (_phoneNoController.text.trim().length != 10) {
      showToast("Invalid phone number. It must be 10 digits after the prefix.");
      return;
    }

    // Validate password and confirm password
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      showToast("Password and confirm password do not match.");
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      showToast("Invalid email format.");
      return;
    }

    try {
           // All checks passed, proceed with user registration
      await AuthenticationRepository.instance.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _userNameController.text.trim(),
        _fullNameController.text.trim(),
        _cnicController.text.trim(),
        '+92${_phoneNoController.text.trim()}',
      );
    } catch (e) {
      // Handle registration errors here (e.g., display an error message)
      showToast("Error during registration: $e");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
    );
  }

}
