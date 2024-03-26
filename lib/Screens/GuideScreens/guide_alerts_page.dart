import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Services/ChatRepository/alert_service.dart';
import '../../Services/ChatRepository/chat_service.dart';
class GuideAlertPage extends StatefulWidget {
  final String tourName;

  const GuideAlertPage({Key? key, required this.tourName}) : super(key: key);

  @override
  _GuideAlertPageState createState() => _GuideAlertPageState();
}

class _GuideAlertPageState extends State<GuideAlertPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService(); // Instance of DatabaseService
  final AlertService _alertService = AlertService(); // Instance of AlertService
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get tourName => null;

  void _sendMessage() async {
    try {
      String message = _messageController.text;

      // Get the logged-in user ID
      String? loggedInUserId = await getCurrentUserId();
      print('Logged-in user ID: $loggedInUserId');

      if (loggedInUserId != null) {
        try {
          // Retrieve the user document to get tour information
          DocumentSnapshot userSnapshot =
          await _databaseService.userCollection.doc(loggedInUserId).get();
          Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

          if (userData != null && userData.containsKey('assignedTour')) {
            String userTourId = userData['assignedTour']; // Retrieve the tour id from user data
            print('User tour ID: $userTourId');

            // Query the "groups" collection to find the group with the matching tourId
            QuerySnapshot groupQuerySnapshot = await _databaseService
                .groupCollection
                .where('groupName', isEqualTo: tourName)
                .get();

            if (groupQuerySnapshot.docs.isNotEmpty) {
              // Assuming there's only one group with this tourId
              String yourGroupId = groupQuerySnapshot.docs.last.id;
              print('Your group ID: $yourGroupId');

              // Save alert to Firebase collection under current group id
              await _databaseService.groupCollection
                  .doc(yourGroupId)
                  .collection('alerts')
                  .add({
                'message': message,
                'timestamp': FieldValue.serverTimestamp(),
              });

              // Retrieve the group data to get member tokens
              DocumentSnapshot groupSnapshot =
              await _databaseService.groupCollection.doc(yourGroupId).get();
              Map<String, dynamic>? groupData =
              groupSnapshot.data() as Map<String, dynamic>?;

              if (groupData != null && groupData.containsKey('members')) {
                List<dynamic> members = groupData['members'];
                print('Members: $members');

                for (String memberData in members) {
                  String memberId = memberData.split('_')[0];
                  String userName = memberData.split('_')[1];
                  print('Member ID: $memberId, Username: $userName');

                  DocumentSnapshot memberSnapshot =
                  await _databaseService.userCollection.doc(memberId).get();

                  if (memberSnapshot.exists) {
                    Map<String, dynamic>? memberData =
                    memberSnapshot.data() as Map<String, dynamic>?;
                    if (memberData != null &&
                        memberData.containsKey('token')) {
                      String? token = memberData['token'];
                      print('Member token: $token');
                      if (token != null) {
                        _alertService.sendPushMessage(
                            token, message, 'Alert');
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error in try block: $e');
        }
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }



  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Alert Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
