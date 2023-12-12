import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_ease_fyp/Widgets/tour_detail_page.dart';

class SlideItem extends StatefulWidget {
  final String name;
  final String imgUrl;
  final int index;
  final PageController pageController;
  final String tourID;
  // ignore: prefer_typing_uninitialized_variables
  var tourDate;
  final String duration;
  final String startDestination;
  final String endDestination;

  SlideItem({
    required this.name,
    required this.imgUrl,
    required this.index,
    required this.pageController,
    required this.tourID,
    required this.tourDate,
    required this.duration,
    required this.startDestination,
    required this.endDestination,
  });

  @override
  _SlideItemState createState() => _SlideItemState();
}

class _SlideItemState extends State<SlideItem> {
  late double page;

  @override
  void initState() {
    super.initState();
    page = widget.index.toDouble();
    widget.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        page = widget.pageController.page!;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    double value = (page - widget.index).abs();
    double scale = 1 - value * 0.3;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailsPage(tourID: widget.tourID),
          ),
        );
      },
      child: Transform.scale(
        scale: scale.clamp(0.5, 1.0),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(
            bottom: 20,
            right: 30,
            top: 50,
          ),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white, // Change color as needed
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.imgUrl,
                    fit: BoxFit.cover,
                    height: 370, // Adjust the height as needed
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, top: 10, right: 15, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10), // Adjust spacing as needed
                    Text(
                      formatTourDate(widget.tourDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Duration: ${widget.duration} days',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Destination: ${widget.endDestination}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTourDate(DateTime? tourDate) {
    if (tourDate != null) {
      return DateFormat.yMMMd().format(tourDate); // You can use any desired date format
    } else {
      return 'Not Available';
    }
  }

}
