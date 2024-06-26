import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:travel_ease_fyp/Services/UserRepository/user_repository.dart';

class PhotosPage extends StatefulWidget {
  @override
  _PhotosPageState createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  late List<String> userImages = [];
  StreamSubscription? _userImagesSubscription;
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late var currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  late String tourUid;
  UserRepository? user;

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      List<String> images = [];
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('images')) {
          List<dynamic> imageUrls = data['images'];
          List<String> images = imageUrls.map((url) => url.toString()).toList();

          // Process the 'images' list as needed
          print('Images array: $images');
        } else {
          print('No images found for the current user.');
        }
      }

      setState(() {
        userImages = images;
      });

// Listen for real-time updates on the current user's document
      _userImagesSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .snapshots()
          .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        List<String> updatedImages = [];
        final data = snapshot.data();
        if (data != null && data.containsKey('images')) {
          List<dynamic> imageUrls = data['images'];
          updatedImages = imageUrls.map((url) => url.toString()).toList();
        }

        setState(() {
          userImages = updatedImages;
        });
      });
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error appropriately, e.g., show error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFa2d19f),
        title: const Text('Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            onPressed: sendFaceRecognitionRequest,
            // Call function to upload images
            tooltip: 'Update Images',
          ),
          IconButton(
            icon: const Icon(Icons.upload_outlined),
            onPressed: _uploadImages, // Call function to upload images
            tooltip: 'Upload Images',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              _downloadImages();
            },
            tooltip: 'Download Images',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFFa2d19f),
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: userImages.length,
          itemBuilder: (BuildContext context, int index) {
            final imageUrl = userImages[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                        child: Text('Failed to load image'));
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<String>> sendFaceRecognitionRequest() async {
    String userID = _auth.currentUser!.uid;
    try {
      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      // Check if user data exists and contains bookings
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('bookings')) {
        List<dynamic> bookings = userData['bookings'];

        // Assuming you want to get the tourUid from the first booking (index 0)
        if (bookings.isNotEmpty) {
          Map<String, dynamic> firstBooking = bookings[0];
          if (firstBooking.containsKey('tourUid')) {
            tourUid = firstBooking['tourUid'];
          } else {
            print('tourUid not found in first booking');
          }
        } else {
          print('No bookings found');
        }
      } else {
        print('User data or bookings not found');
      }
    } catch (e) {
      print('Error uploading images: $e');
      // Handle error, show error message, etc.
    }

    final url = Uri.parse('http://10.100.19.163:5000/face_recognition');
    final body = jsonEncode({'userID': userID, 'tourID': tourUid});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print(response);
    if (response.statusCode == 200) {
      final recognizedImageUrls = List<String>.from(jsonDecode(response.body));

      // Update user document in Firestore with the list of download URLs
      await updateUserImagesInFirestore(userID, recognizedImageUrls);

      return recognizedImageUrls;
    } else {
      throw Exception('Failed to perform face recognition');
    }
  }

  Future<void> updateUserImagesInFirestore(
      String userID, List<String> imageUrls) async {
    try {
      // Get user document reference
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(userID);

      // Loop through each image URL and add it to the 'images' array
      for (String imageUrl in imageUrls) {
        await userRef.update({
          'images': FieldValue.arrayUnion([imageUrl])
        });
      }
    } catch (e) {
      print('Error updating user images in Firestore: $e');
      // Handle error as needed
    }
  }

  Future<void> _uploadImages() async {
    try {
      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      // Check if user data exists and contains bookings
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('bookings')) {
        List<dynamic> bookings = userData['bookings'];

        // Assuming you want to get the tourUid from the first booking (index 0)
        if (bookings.isNotEmpty) {
          Map<String, dynamic> firstBooking = bookings[0];
          if (firstBooking.containsKey('tourUid')) {
            tourUid = firstBooking['tourUid'];

            // Now you have the tourUid, proceed with image upload using tourUid
            final picker = ImagePicker();
            final List<XFile>? images = await picker.pickMultiImage();
            if (images != null) {
              firebase_storage.FirebaseStorage storage =
                  firebase_storage.FirebaseStorage.instance;
              for (int i = 0; i < images.length; i++) {
                XFile image = images[i];
                String imageName =
                    'image_${image.name}_$i'; // Unique image name
                firebase_storage.Reference ref = storage
                    .ref()
                    .child('tours')
                    .child(tourUid) // Use the tourUid retrieved from Firestore
                    .child(imageName);
                await ref.putFile(
                    File(image.path)); // Upload the file using its path
              }
              // Show a success message or update UI as needed
            }
          } else {
            print('tourUid not found in first booking');
          }
        } else {
          print('No bookings found');
        }
      } else {
        print('User data or bookings not found');
      }
    } catch (e) {
      print('Error uploading images: $e');
      // Handle error, show error message, etc.
    }
  }

  Future<void> _downloadImages() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Get the directory path for storing downloaded files
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      final folderPath = '$path/ExploreEase';

      // Create the folder if it doesn't exist
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // Download each image
      for (final imageUrl in userImages) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final fileName = imageUrl.split('/').last;
          final file = File('$folderPath/$fileName');
          await file.writeAsBytes(response.bodyBytes);
        }
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Images downloaded successfully'),
        ),
      );
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _userImagesSubscription?.cancel();
    super.dispose();
  }
}