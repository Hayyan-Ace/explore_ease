import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_ease_fyp/Models/User/user_model.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';
import '../../Services/UserRepository/user_repository.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthenticationRepository.instance.logOut(),
          ),
        ],
      ),
      body: FutureBuilder<MyAppUser?>(
        // Fetch user details asynchronously
        future: UserRepository().getUserDetails(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            // Data has been successfully fetched, display it
            MyAppUser user = snapshot.data!;
            return  SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                        user.profilePicture.isNotEmpty
                            ? user.profilePicture
                            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHiP00HjutvKbqTXIv80K0FJvfejsOVzFagw&usqp=CAU',
                      ),
                    ),
                  ),
                  ProfileField(label: 'Full Name', value: user.fullName),
                  ProfileField(label: 'Username', value: user.username),
                  ProfileField(label: 'Email', value: user.email),
                  ProfileField(label: 'Phone Number', value: user.phoneNo),
                  ProfileField(label: 'CNIC', value: user.cnic),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement edit profile functionality
                      _showEditProfilePopup(user);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => AuthenticationRepository.instance.logOut(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditProfilePopup(MyAppUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: EditProfileForm(user: user),
        );
      },
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  ProfileField({required this.label, required this.value});

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
                readOnly: true,
                controller: TextEditingController(text: value),
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


class EditProfileForm extends StatefulWidget {
  final MyAppUser user;

  EditProfileForm({required this.user});

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  File? _profilePicture; // Added state variable for profile picture
  late String _profileImageURL;
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _profilePicture = null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          // Profile picture selection button
          ElevatedButton(
            onPressed: () => _selectImage(),
            child: const Text('Select Profile Picture'),
          ),
          // Display the selected profile picture
          if (_profilePicture != null)
            Image.file(
              _profilePicture!,
              width: 100,
              height: 100,
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement save changes functionality
              _saveChanges();
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    var imagePicker = ImagePicker();
    var pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload image to Firebase Storage
      String fileName = path.basename(pickedFile.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('usersProfilePictures/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get image URL
      _profileImageURL = await taskSnapshot.ref.getDownloadURL();

      // Update state with image details
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() async {
    try {
      String newUsername = _usernameController.text.trim();
      String newFullName = _fullNameController.text.trim();


      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
        'username': newUsername,
        'fullName': newFullName,
        'profilePicture' : _profileImageURL
      });
    } on FirebaseException catch (e) {
      String errorMessage = "Error updating profile: $e";
      print(errorMessage);
      Fluttertoast.showToast(msg: errorMessage);
    }
  }
}


