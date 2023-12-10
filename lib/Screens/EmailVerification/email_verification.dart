import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Controllers/email_verification_controller.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';
import '../SignUpPage/signup_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailVerificationController());

    return WillPopScope(
      onWillPop: () async {
        // Navigate to SignupScreen when the user swipes to go back
        Get.off(() => SignUpScreen());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Email Verification'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Verify your email address',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We have sent a verification email to your registered email address. Please check your inbox and click on the verification link to activate your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await AuthenticationRepository.instance.sendVerificationEmail();
                },
                child: const Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
