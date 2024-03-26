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

  Future<void> _refreshAlerts() async {
    // You can add any additional logic needed for refreshing here
    setState(() {
      // Update state variables or re-fetch data as needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Alerts'),
        backgroundColor: Colors.white,
        // White background for app bar
        iconTheme: const IconThemeData(color: Color(0xFFa2d19f)), // Icon color
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        color: const Color(0xFFa2d19f), // Refresh indicator color
        backgroundColor: Colors.white, // Background color for refresh indicator
        child: StreamBuilder<QuerySnapshot>(
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
              return const Center(
                child: Text('No alerts received.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();

                // Alternate background color based on index
                Color cardColor = index % 2 == 0 ? Colors.white : const Color(0xFFa2d19f);

                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  color: cardColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0), // Adjusted content padding
                    title: Text(
                      data['title'] ?? 'Alert',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // Making text bold
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text(
                          data['message'] ?? 'No Message',
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Time: ${dateTime.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );

              },
            );
          },
        ),
      ),
    );
  }
}
