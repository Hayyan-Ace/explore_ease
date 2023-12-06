import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/LargeBoldText.dart';
import 'package:travel_ease_fyp/Widgets/firestore_slideshow.dart';




class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 70, left: 20),
            child: Row(
              children: [
                Icon(Icons.menu, size: 30, color: Colors.black54,),
                Expanded(child: Container()),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  width: 50,
                  height: 50,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.indigo.withOpacity(0.5),

                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: LargeBoldText(text: 'Discover'),
          ),
          SizedBox(height: 30),
          Expanded(

            child: SlideshowScreen(),
          ),


        ],


      ),
    );
  }
}
