import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/booking_dialoguebox.dart';

class TourDetailsPage extends StatelessWidget {
  final String name;
  final String imgUrl;
  final String tourID;
  TourDetailsPage({required this.name, required this.imgUrl, required this.tourID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tour Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'tour_${name.toLowerCase()}',
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                height: 200, // Adjust the height as needed
              ),
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showBookingDialog(context),
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingDialog(
          tourName: name,
          tourID: tourID,
        );
      },
    );
  }
}

