import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Widgets/LargeBoldText.dart';
import 'package:travel_ease_fyp/Widgets/firestore_slideshow.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

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
                const Icon(Icons.menu, size: 30, color: Colors.black54,),
                Expanded(child: Container()),
                Container(
                  margin: const EdgeInsets.only(right: 20),
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
