import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/User_Detail_Widget.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> allItems = [];
  late List<Map<String, dynamic>> displayedItems = [];
  bool isLoaded = false;

  late Color myColor;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();

    for (var element in data.docs) {
      tempList.add(element.data());
    }

    setState(() {
      allItems = tempList;
      displayedItems = allItems;
      isLoaded = true;
    });
  }

  _deleteUser(String userId) async {
    try {
      // Delete the user from Firebase Authentication
      await FirebaseAuth.instance.currentUser?.delete();

      // Delete the user data from Firestore
      await collection.doc(userId).delete();

      // You may also want to perform additional cleanup or actions after deletion

      // Refresh the list after deletion
      await _fetchUserData();
    } catch (e) {
      print('Error deleting user: $e');
      // Handle error, if any
    }
  }


  _showUserDetails(String userId, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return UserDetailWidget(
          userData: userData,
          onDeletePressed: () async {
            await _deleteUser(userId);
            Navigator.pop(context);
          },
          onSetAsGuidePressed: () async {
            // Update the user as a guide in Firestore
            await collection.doc(userId).update({
              "isGuide": true,
              "assignedTour": "", // Set assignedTour to an empty string
            });
            // Refresh the data after updating
            await _fetchUserData();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _filterUsers(String query) {
    setState(() {
      displayedItems = allItems
          .where((user) => user["username"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _refreshData() async {
    await _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    myColor = const Color(0xFFa2d19f);
    int totalUsers = displayedItems.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'USERS',
              style: TextStyle(color: Colors.black, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              'Total Users: $totalUsers',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: myColor,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                        controller: searchController,
                        onChanged: _filterUsers,
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
                    ? displayedItems.map((item) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    child: ListTile(
                      onTap: () {if (item["isAdmin"] != true) {
                        _showUserDetails(item["uid"], item);
                      }
                      },
                      contentPadding: const EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CircleAvatar(
                          backgroundColor: myColor,
                          child: const Icon(Icons.person),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(

                            item["username"] + " " ?? "not given",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList()
                    : [const Center(child: CircularProgressIndicator(color: Color(0xFFa2d19f),))],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
