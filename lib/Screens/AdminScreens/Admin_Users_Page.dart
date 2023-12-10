import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'User_Detail_Widget.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items = [];
  bool isLoaded = false;

  late Color myColor;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() async {
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();

    for (var element in data.docs) {
      tempList.add(element.data());
    }

    setState(() {
      items = tempList;
      isLoaded = true;
    });
  }


  _deleteUser(String userId) async {
    await collection.doc(userId).delete();
    // You may also want to perform additional cleanup or actions after deletion
    _fetchUserData(); // Refresh the list after deletion
  }

  _showUserDetails(String userId, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return UserDetailWidget(
          userData: userData,
          onDeletePressed: () {
            _deleteUser(userId);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    myColor = const Color(0xFFa2d19f);
    int totalUsers = items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'USERS',
              style: TextStyle(color: Colors.black, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              'Total Users: $totalUsers',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withOpacity(.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: myColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Icon(Icons.search, color: Colors.black87, size: 22)),
                  )
                ],
              ),
            ),
            Column(
              children: isLoaded
                  ? items.map((item) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () {
                      _showUserDetails(item["uid"], item);
                    },
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CircleAvatar(
                        backgroundColor: myColor,
                        child: Icon(Icons.person),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          item["username"] + " " ?? "not given",
                          style: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item["isAdmin"] == true)
                          Icon(
                            Icons.check_circle,
                            color: myColor,
                            size: 22,
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    subtitle: Text(
                      item["uid"],
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList()
                  : const [Text("loading...")],
            ),
          ],
        ),
      ),
    );
  }
}


