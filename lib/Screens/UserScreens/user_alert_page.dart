import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAlertsPage extends StatefulWidget {
  @override
  _UserAlertsPageState createState() => _UserAlertsPageState();
}

class _UserAlertsPageState extends State<UserAlertsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _alertsStream;

  @override
  void initState() {
    super.initState();
    _subscribeToAlerts();
  }

  void _subscribeToAlerts() {
    // Replace 'group_id' with the actual ID of the group
    _alertsStream = _firestore.collection('groups').doc('zvzG4f8Duhga5y206BDD').collection('alerts').orderBy('timestamp', descending: true).snapshots();
    // Add orderBy clause to sort alerts by timestamp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Alerts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _alertsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No alerts received.'),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              Timestamp timestamp = data['timestamp'] ?? Timestamp.now(); // Access timestamp field
              DateTime dateTime = timestamp.toDate();
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    data['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.0),
                      Text(
                        data['message'] ?? '',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Time: ${dateTime.toString()}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
