import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onTabChange;
  final VoidCallback onLogoutPressed; // Callback for the logout button

  CustomBottomNavigationBar({
    required this.onTabChange,
    required this.onLogoutPressed,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                widget.onLogoutPressed(); // Call the logout function
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return GNav(
      backgroundColor: Colors.lightGreenAccent,
      color: Colors.black,
      activeColor: Colors.black,
      tabBackgroundColor: Colors.lightGreen,
      gap: 0,
      selectedIndex: _selectedIndex,
      onTabChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTabChange(index);

        // Check if the "Logout" button is pressed
        if (index == 4) {
          _showLogoutConfirmationDialog(); // Show the logout confirmation dialog
        } else {
          widget.onTabChange(index);
        }
      },
      tabs: const [
        GButton(icon: Icons.home),
        GButton(icon: Icons.verified_user),
        GButton(icon: Icons.tour),
        GButton(icon: Icons.payment),
        GButton(icon: Icons.logout),
      ],
    );
  }
}
