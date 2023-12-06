import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onTabChange;

  CustomBottomNavigationBar({required this.onTabChange});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

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
