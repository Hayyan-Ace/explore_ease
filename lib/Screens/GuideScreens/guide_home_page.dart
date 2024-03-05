import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GuideHomePage extends StatefulWidget {
  const GuideHomePage({super.key});

  @override
  _GuideHomePageState createState() => _GuideHomePageState();
}

class _GuideHomePageState extends State<GuideHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchTourGuideData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching tour data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildWelcomeContent(snapshot.data!);
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchTourGuideData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await _firestore.collection('users').doc(currentUser.uid).get();
    } else {
      throw Exception('User not logged in');
    }
  }

  Widget _buildWelcomeContent(DocumentSnapshot userSnapshot) {
    String assignedTourID =
    userSnapshot.get('assignedTour'); // Get assigned tour ID

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Tour').doc(assignedTourID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching tour data'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildTourCard(snapshot.data!);
      },
    );
  }

  Widget _buildTourCard(DocumentSnapshot tourSnapshot) {
    // Check if the document exists
    if (!tourSnapshot.exists) {
      return const Center(child: Text('Tour data not available'));
    }

    // Get the data map from the snapshot
    Map<String, dynamic>? data =
    tourSnapshot.data() as Map<String, dynamic>?;

    // Check if the data map is not null and if 'tourName' exists in it
    String tourName = (data != null && data.containsKey('tourName'))
        ? data['tourName'] // Access 'tourName' if it exists
        : 'Unavailable'; // Default to 'Unavailable' otherwise

    return Center(
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(data?['imageUrl'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hello, Tour Guide!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      'Your Assigned Tour: $tourName',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (data != null) ...[
                      const SizedBox(height: 20),
                      _buildTourDetails(data),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourDetails(Map<String, dynamic> tourData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Description: \n${tourData['description'] ?? 'Not Available'}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Tour Date: ${_formatTourDate(tourData['tourDate'])}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Duration: ${tourData['duration'] ?? 'Not Available'} days',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Departure Location: ${tourData['startingPoint'] ?? 'Not Available'}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Destination: ${tourData['endPoint'] ?? 'Not Available'}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'Price: ${tourData['price'] ?? 'Not Available'} Rupees',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _formatTourDate(dynamic tourDate) {
    if (tourDate is Timestamp) {
      DateTime dateTime = tourDate.toDate();
      return DateFormat.yMMMd().format(dateTime); // You can use any desired date format
    } else if (tourDate is DateTime) {
      return DateFormat.yMMMd().format(tourDate);
    } else {
      return 'Not Available';
    }
  }
}

