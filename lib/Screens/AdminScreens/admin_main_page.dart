import 'package:flutter/material.dart';
import '../../Widgets/NavBar_Admin.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

// ... rest of your code
}
