import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();

  late Color myColor;

  SignUpScreen({super.key});

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
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cnicController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13), // Limit to 13 digits
                ],
                decoration:
                    const InputDecoration(labelText: 'CNIC (13 digits)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneNoController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone No',
                  prefixText: '+92 ',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 20,
                  shadowColor: myColor,
                  backgroundColor: myColor.withOpacity(0.9),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () => _registerUser(),
                child: const Text('Sign Up',
                    style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Log in here',
                    style: TextStyle(color: Colors.black87)),
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
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
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
