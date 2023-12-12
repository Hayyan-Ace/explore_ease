import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late CollectionReference<Map<String, dynamic>> collection;
  late List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        collection = FirebaseFirestore.instance.collection("users");
      });
      await _fetchUserData();
    }
  }

  _fetchUserData() async {
    List<Map<String, dynamic>> tempList = [];
    var userData = await collection.doc(_user.uid).get();

    if (userData.exists) {
      var bookings = userData.data()?['bookings'] ?? [];
      bookings.forEach((booking) {
        if (booking is Map<String, dynamic>) {
          var verified = booking['verified'];
          var tourName = booking['tourName'];

          if (verified is bool && tourName is String) {
            tempList.add({
              'verified': verified,
              'tourName': tourName,
            });
          }
        }
      });
    }

    setState(() {
      items = tempList;
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Group'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: items.map((item) {
            return Card(
              color: Colors.white,
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  'Tour: ${item['tourName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Row(
                  children: [
                    const Text(
                      'Payment Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['verified']
                          ? 'Confirmed ✓' // Green tick for true
                          : 'pending confirmation', // Red cross for false
                      style: TextStyle(
                        color: item['verified'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}