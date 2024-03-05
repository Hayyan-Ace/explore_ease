import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Services/chat_service.dart';
import 'chat_page.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String username = "";
  late CollectionReference<Map<String, dynamic>> collection;
  late List<Map<String, dynamic>> items = [];
  Stream? groups;
  String currentTourName = ""; // Store the current tour name for app bar
  bool currentTourVerified =
      false; // Store the current tour verification status

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
            });
          }
        }
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
            content: const Text("The payment for this tour is pending confirmation."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Tour Group: $currentTourName',
          style: const TextStyle(
          color: Colors.black,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),), // Update app bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    currentTourVerified
                        ? 'Confirmed ✓'
                        : 'Pending Confirmation',
                    style: TextStyle(
                      color: currentTourVerified ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Spacer
            // Chat Card
            // Chat Card
            // Chat Card
            GestureDetector(
              onTap: currentTourVerified ? () {
                openChatForTour(currentTourName, currentTourVerified);
              } : null, // Set onTap to null when payment is not confirmed
              child: Card(
                color: Colors.white,
                elevation: 3,
                child: Opacity(
                  opacity: currentTourVerified ? 1.0 : 0.5, // Reduce opacity if disabled
                  child: const ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(Icons.chat),
                    title: Text('Chat'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Spacer
            // Photos Card
            GestureDetector(
              onTap: () {
                // Handle photos card tap
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
                // Handle alerts card tap
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
              onTap: () {
                // Handle tour tracking card tap
              },
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


