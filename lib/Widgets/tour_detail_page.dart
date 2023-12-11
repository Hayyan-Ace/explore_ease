import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/booking_dialoguebox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TourDetailsPage extends StatelessWidget {
  final String tourID;

  TourDetailsPage({required this.tourID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Tour').doc(tourID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Tour details not available'));
          } else {
            var tourData = snapshot.data!.data() as Map<String, dynamic>?;

            if (tourData == null) {
              return Center(child: Text('Tour details not available'));
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
          image: NetworkImage(tourData['imageUrl']),
          // Replace with your image path
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
            tourData['tourName'],
            style: TextStyle(
              color: Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildDescriptionBox(context, tourData['description'] ?? ''),
        // Add null check and provide a default value
        _buildDetailRow("Duration", "${tourData['duration']} days"),
        _buildDetailRow("Departure Location", tourData['startingPoint']),
        _buildDetailRow("Destination", tourData['endPoint']),
        _buildDetailRow("Price", "${tourData['price']} Rupees"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showBookingDialog(context),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            elevation: 20,
            shadowColor: Color(0xFFa2d19f),
            backgroundColor: Color(0xFFa2d19f).withOpacity(0.9),
            minimumSize: const Size.fromHeight(60),
          ),
          child: Text(
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
          height: 100, // Set a fixed height for a brief description
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _formatDescription(description),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
              ),
              maxLines: 3, // Limit the number of lines for a brief description
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
          title: Text("Tour Description"),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDescription(String description) {
    // Split the description at "Day" + some number + ":" and add a line break before "Day" and after ":"
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
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

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Replace with your BookingDialog
        return BookingDialog(
          tourName: tourID,
          tourID: tourID,
        );
      },
    );
  }
}
