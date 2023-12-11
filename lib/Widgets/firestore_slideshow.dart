import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_ease_fyp/Widgets/slide_item_tour.dart';

class SlideshowScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Adjust the height as needed
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Tour').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFa2d19f),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          var slides = snapshot.data!.docs;

          return PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              var slide = slides[index];
              var name = slide['tourName'];
              var imageUrl = slide['imageUrl'];
              var tourID = slide.id;

              var tourDate = slide['tourDate'];
              if (tourDate != null) {
                tourDate = tourDate.toDate();
              }

              var duration = slide['duration'];
              var startDestination = slide['startingPoint'];
              var endDestination = slide['endPoint'];

              return SlideItem(
                tourID: tourID,
                name: name,
                imgUrl: imageUrl,
                index: index,
                pageController: _pageController,
                tourDate: tourDate,
                duration: duration,
                startDestination: startDestination,
                endDestination: endDestination,
              );
            },
          );
        },
      ),
    );
  }
}
