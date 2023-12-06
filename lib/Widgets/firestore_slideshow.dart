import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_ease_fyp/Widgets/slide_item_tour.dart';

class SlideshowScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController(viewportFraction: 0.7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Tour').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Text('No data available');
          }

          var slides = snapshot.data!.docs;

          return PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              var slide = slides[index];
              var name = slide['tourName'];
              var imgUrl = slide['imgURL'];
              var tourID = slide.id;

              return SlideItem(
                tourID: tourID,
                name: name,
                imgUrl: imgUrl,
                index: index,
                pageController: _pageController,
              );
            },
          );
        },
      ),
    );
  }
}
