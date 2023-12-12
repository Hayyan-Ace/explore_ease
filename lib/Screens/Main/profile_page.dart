import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  String _profileImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Page',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Fetch user details asynchronously
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            // Data has been successfully fetched, display it
            Map<String, dynamic>? userData =
            snapshot.data!.data() as Map<String, dynamic>?;

            if (userData != null) {
              // Set the text in the controllers
              _fullNameController.text = userData['fullName'] ?? '';
              _usernameController.text = userData['username'] ?? '';
              _emailController.text = userData['email'] ?? '';
              _phoneNoController.text = userData['phoneNo'] ?? '';
              _cnicController.text = userData['cnic'] ?? '';

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Show a pop-up menu with options
                        final result = await showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(100, 200, 50, 0),
                          items: const [
                            PopupMenuItem(
                              child: Text('Update'),
                              value: 'change',
                            ),
                            PopupMenuItem(
                              child: Text('Remove'),
                              value: 'remove',
                            ),
                          ],
                        );

                        // Handle the selected option
                        if (result != null) {
                          if (result == 'change') {
                            // Open the gallery to select an image
                            File? imageFile = await _pickImage(ImageSource.gallery);
                            if (imageFile != null) {
                              // Upload the selected image to Firebase
                              String imageUrl = await _uploadImage(
                                  _auth.currentUser!.uid, imageFile);
                              setState(() {
                                _profileImageUrl = imageUrl;  // Use 'imageUrl' here
                              });
                            }
                          } else if (result == 'remove') {
                            // Set the current image as the profile picture
                            // (You can implement the logic to remove the image from Firebase if needed)
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(_profileImageUrl),
                        ),
                      ),
                    ),

                    ProfileField(
                      label: 'Full Name',
                      value: _fullNameController.text,
                      controller: _fullNameController,
                    ),
                    ProfileField(
                      label: 'Username',
                      value: _usernameController.text,
                      controller: _usernameController,
                    ),
                    ProfileField(
                      label: 'Email',
                      value: _emailController.text,
                      controller: _emailController,
                      readOnly: true,
                    ),
                    ProfileField(
                      label: 'Phone Number',
                      value: _phoneNoController.text,
                      controller: _phoneNoController,
                    ),
                    ProfileField(
                      label: 'CNIC',
                      value: _cnicController.text,
                      controller: _cnicController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Get the updated values from text fields
                        String userId = _auth.currentUser!.uid;
                        String fullName = _fullNameController.text;
                        String username = _usernameController.text;
                        String email = _emailController.text;
                        String phoneNo = _phoneNoController.text;
                        String cnic = _cnicController.text;

                        // Reference to the user document in Firestore
                        final userDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId);

                        try {
                          // Update the user's data in Firestore
                          await userDoc.update({
                            'fullName': fullName,
                            'username': username,
                            'email': email,
                            'phoneNo': phoneNo,
                            'cnic': cnic,
                          });

                          Fluttertoast.showToast(
                              msg: 'Profile updated successfully');
                        } catch (error) {
                          print('Error updating user details: $error');
                          // Handle the error as needed
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFa2d19f),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('User data is null'));
            }
          }
        },
      ),
    );
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }


  Future<String> _uploadImage(String userId, File imageFile) async {
    // Upload the image to Firebase Storage and return the download URL
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$userId.${path.extension(imageFile.path)}');

    try {
      // Upload the image file
      await storageReference.putFile(imageFile);

      // Get the download URL
      String downloadURL = await storageReference.getDownloadURL();
      print('Download URL: $downloadURL');

      // Save the download URL in the user's data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePicture': downloadURL});  // Use 'profilePicture' here

      return downloadURL;
    } catch (error) {
      print('Error uploading image: $error');
      return ''; // Handle the error as needed
    }
  }


}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController? controller;
  final bool readOnly; // Add this property

  ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.controller,
    this.readOnly = false, // Set a default value
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: controller,
                readOnly: readOnly, // Set readOnly property
                decoration: InputDecoration(
                  labelText: label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
