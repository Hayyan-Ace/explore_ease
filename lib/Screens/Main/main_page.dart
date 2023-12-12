import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/Admin_Logout_Page.dart';
import 'package:travel_ease_fyp/Screens/Main/chat_screen.dart';
import 'package:travel_ease_fyp/Screens/Main/profile_page.dart';

import '../../Services/AuthentactionRepository/authentication_repository.dart';
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
      ProfilePage(),
      const AdminLogoutPage(),
  ];

    int currentIndexNavBar = 0;

    void onTapNavBar(int index) {
      if (index == pages.length - 1) {
        // If the "Logout" button is tapped, show confirmation dialog
        showLogoutConfirmationDialog();
      } else {
        setState(() {
          currentIndexNavBar = index;
        });
      }
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
          BottomNavigationBarItem(label: 'Tour Group',icon: Icon(Icons.chat)),
          BottomNavigationBarItem(label: 'Profile',icon: Icon(Icons.person_2)),
          BottomNavigationBarItem(label: 'Logout',icon: Icon(Icons.logout, color: Colors.red,),),

          ]
      ),
    );
  }



    void showLogoutConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Logout Confirmation'),
            content: const Text('Are you sure you want to logout?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: () {
                  // Perform logout action
                  AuthenticationRepository.instance.logOut();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Logout',style: TextStyle(color: Color(0xFFa2d19f)),),
              ),
            ],
          );
        },
      );
    }
}
