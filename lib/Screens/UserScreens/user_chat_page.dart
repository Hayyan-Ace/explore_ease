import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Screens/UserScreens/user_alert_page.dart';
import 'package:travel_ease_fyp/Screens/UserScreens/user_tracking_page.dart';
import '../../PhotosScreen/photo_page.dart';
import '../../Services/ChatRepository/chat_service.dart';
import '../ChatScreens/chat_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class UserChatPage extends StatefulWidget {
  @override
  _UserChatPageState createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String username = "";
  late CollectionReference<Map<String, dynamic>> collection;
  late List<Map<String, dynamic>> items = [];
  Stream? groups;
  String currentTourName = ""; // Store the current tour name for app bar
  bool currentTourVerified = false; // Store the current tour verification status
  bool isTourGroupActive = false;
  bool hasUploadedPhotos = false; // Flag to track if user has uploaded photos

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // Inside getCurrentUser() method
  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        collection = FirebaseFirestore.instance.collection("users");
      });

      await fetchUserData();

      // Fetch username from Firestore
      var userData = await collection.doc(_user.uid).get();
      setState(() {
        username = userData.data()?['username'] ?? '';
      });
    }
  }

  // Inside fetchUserData() method
  fetchUserData() async {
    var userData = await collection.doc(_user.uid).get();

    if (userData.exists) {
      var bookings = userData.data()?['bookings']; // Retrieve the bookings data

      if (bookings is List && bookings.isNotEmpty) {
        // Check if bookings is a non-empty list
        var firstBooking = bookings.first; // Get the first booking

        if (firstBooking is Map<String, dynamic>) {
          // Check if first booking is a Map
          var verified = firstBooking['verified'];
          var tourName = firstBooking['tourName'];

          if (verified is bool && tourName is String) {
            setState(() {
              currentTourVerified = verified;
              currentTourName = tourName; // Update the current tour name
              isTourGroupActive = true;
            });
          }
        }
      }

      // Check if user has uploaded photos
      var hasPhotos = userData.data()?['hasPhotos'];
      if (hasPhotos != null && hasPhotos is bool && hasPhotos) {
        setState(() {
          hasUploadedPhotos = true;
        });
      }
    }
  }

  // Inside openChatForTour() method
  void openChatForTour(String tourName, bool verified) async {
    if (verified) {
      // Fetch the tour group's information
      var groupData = await DatabaseService().searchByName("Tour_$tourName");

      // If the tour group exists, navigate to the chat page for that group
      if (groupData.docs.isNotEmpty) {
        var groupId = groupData.docs.first.id;
        var groupName = groupData.docs.first.data()['groupName'];
        setState(() {
          currentTourName = tourName; // Update the current tour name
          currentTourVerified = verified; // Update verification status
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Chat(
                  groupId: groupId,
                  groupName: groupName,
                  userName: username,
                ),
          ),
        );
      } else {
        // Handle if the tour group does not exist
      }
    } else {
      // Handle if the payment is not confirmed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Payment Pending"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("The payment for this tour is pending confirmation."),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to upload photos here
                    uploadPhotos();
                  },
                  child: const Text("Upload Photos"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

// Function to pick photos from the device gallery
  Future<List<XFile>?> pickPhotos() async {
    final picker = ImagePicker();
    try {
      // Pick multiple images from the gallery
      List<XFile>? pickedFiles = await picker.pickMultiImage();
      return pickedFiles;
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }



// Function to upload photos to Firebase Storage
  Future<void> uploadPhotos() async {
    // Pick photos from the device gallery
    List<XFile>? selectedPhotos = await pickPhotos();

    if (selectedPhotos != null && selectedPhotos.length >= 2) {
      // Get a reference to the Firebase Storage location
      var storage = firebase_storage.FirebaseStorage.instance;
      var storageRef = storage.ref().child('training_data/${_user.uid}');

      // Upload each selected photo
      for (var photo in selectedPhotos) {
        var fileNameWithExtension = photo.name; // Get the file name with extension
        var photoRef = storageRef.child(fileNameWithExtension);

        try {
          // Convert the XFile to a File object
          File file = File(photo.path);

          // Upload the file
          await photoRef.putFile(file);
        } catch (e) {
          print('Error uploading photo: $e');
        }
      }

      // Update hasUploadedPhotos flag
      setState(() {
        hasUploadedPhotos = true;
      });

      // Close the dialog
      Navigator.of(context).pop();

      // Refresh the page
      getCurrentUser(); // Call getCurrentUser to refresh the user data
    } else {
      // Show an error message if less than 25 photos are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 25 photos.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(
        'Tour Group: $currentTourName',
        style: const TextStyle(
        color: Colors.black,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        fontSize: 24,
    ),
    ),
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    if (isTourGroupActive)
    Container(
    padding: const EdgeInsets.all(8),
    color: Colors.grey.shade200,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    'Payment Status:',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    ),
    ),
      Text(
        currentTourVerified ? 'Confirmed ✓' : 'Pending Confirmation',
        style: TextStyle(
          color: currentTourVerified ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
    ),
    ),
      const SizedBox(height: 20), // Spacer
      if (isTourGroupActive && currentTourVerified)
        GestureDetector(
          onTap: () {
            openChatForTour(currentTourName, currentTourVerified);
          },
          child: const Card(
            color: Colors.white,
            elevation: 3,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.chat),
              title: Text('Chat'),
            ),
          ),
        )
      else if (!isTourGroupActive)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No Bookings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        )
      else // If tour is active but payment is pending
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Payment Pending',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      const SizedBox(height: 20), // Spacer
      // Photos Card
      GestureDetector(
        onTap: () {
          if (hasUploadedPhotos) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhotosPage()),
            );
          } else {
            // Prompt user to upload photos first
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("Upload Photos", style: TextStyle(color: Color(0xFFa2d19f))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("You need to upload photos before accessing this feature.", style: TextStyle(color: Colors.black)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Add functionality to upload photos here
                          uploadPhotos();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xFFa2d19f), // background color
                        ),
                        child: const Text("Upload Photos"),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Card(
          color: Colors.white,
          elevation: 3,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(Icons.photo),
            title: Text('Photos'),
          ),
        ),
      ),
      const SizedBox(height: 20), // Spacer
      // Alerts Card
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAlertsPage(),
            ),
          );
        },
        child: const Card(
          color: Colors.white,
          elevation: 3,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(Icons.notifications),
            title: Text('Alerts'),
          ),
        ),
      ),
      const SizedBox(height: 20), // Spacer
      // Tour Tracking Card
      GestureDetector(
        /* onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserTrackingPage(),
                  ),
                );
              },*/
        child: const Card(
          color: Colors.white,
          elevation: 3,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(Icons.location_on),
            title: Text('Track Tour'),
          ),
        ),
      ),
    ],
    ),
    ),
    );
  }
}
