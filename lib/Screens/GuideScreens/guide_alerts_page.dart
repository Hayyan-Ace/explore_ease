import 'package:flutter/material.dart';

class GuideAlertPage extends StatefulWidget {
  @override
  _GuideAlertPageState createState() => _GuideAlertPageState();
}

class _GuideAlertPageState extends State<GuideAlertPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    // Implement logic to send notification
    String message = _messageController.text;
    // Send message to Firebase Cloud Messaging (FCM) for notification delivery
    // You may need to use FCM API or a similar service to send notifications
    // Example:
    // firebaseMessaging.send(message);
    // You need to replace `firebaseMessaging.send(message)` with your actual implementation
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
