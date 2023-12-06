import 'package:flutter/material.dart';
import '../../Services/AuthentactionRepository/authentication_repository.dart';
import '../../Widgets/NavBar_Admin.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;

  void handleLogout() {
    // Implement your logout logic here
    AuthenticationRepository.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onLogoutPressed: handleLogout,
      ),
    );
  }

// ... rest of your code
}



class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.white,
        body: Column(children: <Widget>[
          SizedBox(
            height: 110,
          ),
          Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("EploreEase",),
                    SizedBox(height: 4,),
                    Text("Admin",),
                    IconButton(
                      alignment: Alignment.topCenter,
                      icon: Image.asset("assets/notification.png"),
                      onPressed: () {  },),

                  ],
                )
              ],
            ),
          ),
        SizedBox(
          height: 40,
        ),
        ],
        ),
      );
  }

}
