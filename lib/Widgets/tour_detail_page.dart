import 'package:flutter/material.dart';

class TourDetailsPage extends StatelessWidget {
  final String name;
  final String imgUrl;

  TourDetailsPage({required this.name, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4, // Adjust height
            child: Hero(
              tag: 'tour_${name.toLowerCase()}',
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.0)),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add more details here like cost, location, etc.
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle booking button click
                    Navigator.of(context).pop(); // Close the details page
                  },
                  child: Text('Book Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
