import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../UserScreens/chat_page.dart';

class GuideChatPage extends StatefulWidget {
  const GuideChatPage({Key? key}) : super(key: key);

  @override
  _GuideChatPageState createState() => _GuideChatPageState();
}

class _GuideChatPageState extends State<GuideChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String username = "";
  late CollectionReference<Map<String, dynamic>> collection;
  late String currentTourId = "";
  late String currentTourName = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // Fetch current user data
  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        collection = FirebaseFirestore.instance.collection("users");
      });

      // Fetch username and assignedTour from Firestore
      var userData = await collection.doc(_user.uid).get();
      setState(() {
        username = userData.data()?['username'] ?? '';
        currentTourId = userData.data()?['assignedTour'] ?? '';
      });

      // Fetch tour name using the assignedTour ID
      var tourData =
      await FirebaseFirestore.instance.collection("Tour").doc(currentTourId).get();
      setState(() {
        currentTourName = tourData.data()?['tourName'] ?? '';
      });
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
            // Chat Card
            GestureDetector(
              onTap: () {
                openChatForTour(currentTourName, true); // Assuming payment is always verified for tour guides
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

  void openChatForTour(String tourName, bool verified) async {
    // Fetch the tour group's information
    var groupData = await FirebaseFirestore.instance
        .collection("groups")
        .where("admin", isEqualTo: "${_user.uid}_$username")
        .where("groupName", isEqualTo: "Tour_$tourName")
        .get();

    // If the tour group exists and the logged-in user is the admin, navigate to the chat page for that group
    if (groupData.docs.isNotEmpty) {
      var groupId = groupData.docs.first.id;
      var groupName = groupData.docs.first.data()['groupName'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            groupId: groupId,
            groupName: groupName,
            userName: username,
          ),
        ),
      );
    } else {
      // Handle if the tour group does not exist or the user is not the admin
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("You are not authorized to access this chat."),
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

}
