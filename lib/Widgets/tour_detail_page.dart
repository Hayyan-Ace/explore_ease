// tour_detail_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_ease_fyp/Widgets/booking_dialoguebox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TourDetailsPage extends StatelessWidget {
  final String tourID;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TourDetailsPage({required this.tourID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Tour').doc(tourID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tour details not available'));
          } else {
            var tourData = snapshot.data!.data() as Map<String, dynamic>?;

            if (tourData == null) {
              return const Center(child: Text('Tour details not available'));
            }

            return _buildTourDetails(context, tourData);
          }
        },
      ),
    );
  }

  Widget _buildTourDetails(
      BuildContext context, Map<String, dynamic> tourData) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            tourData['imageUrl'],
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(bottom: 0, child: _buildBottom(context, tourData)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom(BuildContext context, Map<String, dynamic> tourData) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(context, tourData),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Map<String, dynamic> tourData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            tourData['tourName'] ?? 'Tour Name Not Available',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildDescriptionBox(context, tourData['description'] ?? ''),
        if (tourData['tourDate'] != null)
          _buildDetailRow("Tour Date", _formatTourDate(tourData['tourDate'])),
        _buildDetailRow(
            "Duration", "${tourData['duration'] ?? 'Not Available'} days"),
        _buildDetailRow(
            "Departure Location", tourData['startingPoint'] ?? 'Not Available'),
        _buildDetailRow("Destination", tourData['endPoint'] ?? 'Not Available'),
        _buildDetailRow(
            "Price", "${tourData['price'] ?? 'Not Available'} Rupees"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showBookingDialog(context, tourData),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            elevation: 20,
            shadowColor: const Color(0xFFa2d19f),
            backgroundColor: const Color(0xFFa2d19f).withOpacity(0.9),
            minimumSize: const Size.fromHeight(60),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(BuildContext context, String description) {
    return GestureDetector(
      onTap: () =>
          _showDescriptionPopup(context, _formatDescription(description)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _formatDescription(description),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _showDescriptionPopup(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Tour Description"),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  String _formatDescription(String description) {
    List<String> parts = description.split(RegExp(r'(?=Day \d+:)'));
    String formattedDescription = parts.map((part) => '\n$part\n').join();
    return formattedDescription.trim();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  void _showBookingDialog(
      BuildContext context, Map<String, dynamic> tourData) async {
    // Check if the user already has a booking
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null &&
        userData['bookings'] != null &&
        (userData['bookings'] as List).isNotEmpty) {
      // User already has a booking, show an error message or take appropriate action
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('You can only book one tour at a time.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // User does not have a booking, proceed to show the booking dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Replace with your BookingDialog
          return BookingDialog(
            tourName: tourData['tourName'] ?? 'Tour Name Not Available',
            tourID: tourData['tourId'] ?? 'Tour ID Not Available',
            tourDate: '',
          );
        },
      );
    }
  }

  String _formatTourDate(dynamic tourDate) {
    if (tourDate is Timestamp) {
      DateTime dateTime = tourDate.toDate();
      return DateFormat.yMMMd()
          .format(dateTime); // You can use any desired date format
    } else if (tourDate is DateTime) {
      return DateFormat.yMMMd().format(tourDate);
    } else {
      return 'Not Available';
    }
  }
}
