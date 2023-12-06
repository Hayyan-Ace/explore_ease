import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_ease_fyp/Models/User/user_model.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';
import '../../Services/UserRepository/user_repository.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: FutureBuilder<MyAppUser?>(
        // Fetch user details asynchronously
        future: UserRepository().getUserDetails(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data available'));
          } else {
            // Data has been successfully fetched, display it
            MyAppUser user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user.profilePicture.isNotEmpty
                          ? user.profilePicture
                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHiP00HjutvKbqTXIv80K0FJvfejsOVzFagw&usqp=CAU',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => AuthenticationRepository.instance.logOut(),
                      // Navigate back to the sign-in screen (you can replace it with your desired destination)


                    child: Text('Sign Out'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
