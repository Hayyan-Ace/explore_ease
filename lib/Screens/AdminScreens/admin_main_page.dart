import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../Services/AuthentactionRepository/authentication_repository.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
        backgroundColor: Colors.lightGreenAccent,
        color: Colors.black,
        activeColor: Colors.black,
        tabBackgroundColor: Colors.lightGreen,
        gap: 0,
        selectedIndex: _selectedIndex, // Add this line to set the selected index
        onTabChange: (index) {
          // Add this function to handle tab changes
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: const [
          GButton(icon: Icons.home, ),
          GButton(icon: Icons.verified_user, ),
          GButton(icon: Icons.tour,  ),
          GButton(icon: Icons.payment,  ),
          GButton(icon: Icons.logout, ),
        ],
      ),

    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.white : Colors.grey,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage();
      case 1:
        return UserManagementPage();
    // Add more cases for additional pages
      default:
        return Container();
    }
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dashboard'),
    );
  }
}

class UserManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('User Management'),
    );
  }
}