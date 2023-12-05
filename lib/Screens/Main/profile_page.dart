import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              // Display user's profile picture here
              radius: 50,
              // You can use the user's profile picture URL from Firebase or any other source
              backgroundImage: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHiP00HjutvKbqTXIv80K0FJvfejsOVzFagw&usqp=CAU',
              ),
            ),
            SizedBox(height: 20),
            Text(
              // Display user's display name here
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AuthenticationRepository.instance.logOut(),
                // Sign out the userawait _auth.signOut();
                // Navigate back to the sign-in screen (you can replace it with your desired destination)

              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
