import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Screens/Main/chat_screen.dart';
import 'package:travel_ease_fyp/Screens/Main/profile_page.dart';

import 'home_screen.dart';

class MainPage extends StatefulWidget{
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{
    List pages = [
    const HomeScreen(),
    const ChatPage(),
      ProfilePage()
  ];

  int currentIndexNavBar = 0;
  void onTapNavBar(int index){
    setState(() {
    currentIndexNavBar = index;
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: pages[currentIndexNavBar],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        currentIndex: currentIndexNavBar,
        onTap: onTapNavBar,
        unselectedFontSize: 0,

        items: [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'Chat',icon: Icon(Icons.chat)),
          BottomNavigationBarItem(label: 'Profile',icon: Icon(Icons.person)),
        ]
      ),
    );
  }


}
