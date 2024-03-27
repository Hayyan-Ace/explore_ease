import 'package:flutter/material.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_home_page.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_logout_page.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_payment_page.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_tours_page.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_users_page.dart';
import '../../Services/AuthentactionRepository/authentication_repository.dart';

class AdminPanelMain extends StatefulWidget{
  const AdminPanelMain({super.key});
  @override
  _AdminPanelMainState createState() => _AdminPanelMainState();
}

class _AdminPanelMainState extends State<AdminPanelMain>{
  List pages = [
    const AdminHomePage(),
    const AdminUsersPage(),
    const AdminToursPage(),
    const AdminPaymentPage(),
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: pages[currentIndexNavBar],
      bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: currentIndexNavBar,
          onTap: onTapNavBar,
          unselectedFontSize: 0,
          selectedIconTheme: const IconThemeData(color: Color(0xFFa2d19f)), // Set the default color for selected icons
          unselectedIconTheme: const IconThemeData(color: Colors.black), // Set the default color for unselected icons
          selectedItemColor: const Color(0xFFa2d19f), // Set the font color for the selected item

          items: const [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Users',icon: Icon(Icons.person)),
            BottomNavigationBarItem(label: 'Tours',icon: Icon(Icons.tour)),
            BottomNavigationBarItem(label: 'Payments',icon: Icon(Icons.payment)),
            BottomNavigationBarItem(label: 'Logout',icon: Icon(Icons.logout, color: Colors.red,),),
          ]
      ),
    );
  }

}
