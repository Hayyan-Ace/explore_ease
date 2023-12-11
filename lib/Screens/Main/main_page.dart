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
      bottomNavigationBar: BottomNavigationBar(showUnselectedLabels: false,
          currentIndex: currentIndexNavBar,
          onTap: onTapNavBar,
          unselectedFontSize: 0,
          selectedIconTheme: const IconThemeData(color: Color(0xFFa2d19f)), // Set the default color for selected icons
          unselectedIconTheme: const IconThemeData(color: Colors.black), // Set the default color for unselected icons
          selectedItemColor: Color(0xFFa2d19f), // Set the font color for the selected item


          items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'Chat',icon: Icon(Icons.chat)),
          BottomNavigationBarItem(label: 'Settings',icon: Icon(Icons.settings)),
        ]
      ),
    );
  }


}
