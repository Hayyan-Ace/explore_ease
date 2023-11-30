import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_ease_fyp/presentation/login_screen.dart';

import '../../presentation/login_screen.dart';
import 'intro_screen_1.dart';
import 'intro_screen_2.dart';
import 'intro_screen_3.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  PageController _controller = PageController();

  //keep track of last page
  bool onLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
       children: [
         PageView(
           controller: _controller,
           onPageChanged: (index){
             setState(() {
               onLastPage = (index == 2);
             });
           },
           children: [
             IntroPage1(),
             IntroPage2(),
             IntroPage3(),
           ],
          ),

         Container(
           alignment: Alignment(0,0.9),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 //skip
                 GestureDetector(
                     onTap:() {
                       _controller.jumpToPage(2);
                    },
                     child: Text('Skip')),

                 //dot indicator
                 SmoothPageIndicator(controller: _controller, count: 3),
                //next or done
                 onLastPage ?
                 GestureDetector(
                     onTap:() {
                       Navigator.push(context,MaterialPageRoute(builder: (context){
                         return LoginScreen();
                       }));

                     },
                       child: Text('Done'),

                 )
                     :GestureDetector(
                   onTap:() {
                     _controller.nextPage(
                       duration: Duration(milliseconds: 500),
                       curve: Curves.easeIn,
                     );
                   },
                     child: Text('Next'),
                 ) ,
               ],
             )),
       ],
      )
    );
  }
}
