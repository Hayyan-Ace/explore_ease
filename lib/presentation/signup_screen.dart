import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:fluttertoast/fluttertoast.dart";
import 'package:travel_ease_fyp/Main/main_page.dart';
import '../Main/home_screen.dart';

class SignUpScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();


      _auth.isSignInWithEmailLink(email);

      if (password != confirmPassword) {
        print("Password is not correct");

        return;
      }

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Fluttertoast.showToast(msg: 'User signed up: ${userCredential.user!.email}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );

      print('User signed up: ${userCredential.user!.uid}');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
      // Navigate to the home screen or perform other actions
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error during sign-up: $e';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email')
        errorMessage = 'The email address is not valid';


      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );
      print('Firebase Auth Error: $errorMessage');
    }
  }


  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _signUp(context),
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
