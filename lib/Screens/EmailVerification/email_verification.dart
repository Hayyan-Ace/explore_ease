import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Controllers/email_verification_controller.dart';

class EmailVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(EmailVerificationController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Verify your email address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'We have sent a verification email to your registered email address. Please check your inbox and click on the verification link to activate your account.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Implement the action when the user clicks the button
              },
              child: Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}