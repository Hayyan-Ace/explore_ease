import 'package:flutter/material.dart';

import 'package:travel_ease_fyp/Widgets/tour_detail_page.dart';

class SlideItem extends StatefulWidget {
  final String name;
  final String imgUrl;
  final int index;
  final PageController pageController;
  final String tourID;
  SlideItem({
    required this.name,
    required this.imgUrl,
    required this.index,
    required this.pageController,
    required this.tourID
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TourDetailsPage(name: widget.name, imgUrl: widget.imgUrl, tourID: widget.tourID);
          },
        );
      },
      child: Transform.scale(
        scale: scale.clamp(0.5, 1.0),
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 20,
            right: 30,
            top: 50,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.imgUrl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(20, 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
