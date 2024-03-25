import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Services/ChatRepository/alert_service.dart';
import '../../Services/ChatRepository/chat_service.dart';

class GuideAlertPage extends StatefulWidget {
  @override
  _GuideAlertPageState createState() => _GuideAlertPageState();
}

class _GuideAlertPageState extends State<GuideAlertPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService(); // Instance of DatabaseService
  final AlertService _alertService = AlertService(); // Instance of AlertService


  void _sendMessage() async {
    String message = _messageController.text;
    String yourGroupId = "zvzG4f8Duhga5y206BDD";

    try {
      DocumentSnapshot groupSnapshot =
      await _databaseService.groupCollection.doc(yourGroupId).get();
      Map<String, dynamic>? groupData =
      groupSnapshot.data() as Map<String, dynamic>?;

      if (groupData != null && groupData.containsKey('members')) {
        List<dynamic> members = groupData['members'];

        for (String memberData in members) {
          String memberId = memberData.split('_')[0];
          String userName = memberData.split('_')[1];

          DocumentSnapshot userSnapshot =
          await _databaseService.userCollection.doc(memberId).get();

          if (userSnapshot.exists) {
            Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
            if (userData != null && userData.containsKey('token')) {
              String? token = userData['token'];
              if (token != null) {
                _alertService.sendPushMessage(token, message, 'Alert');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
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
