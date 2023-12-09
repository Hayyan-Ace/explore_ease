import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() async {
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();

    data.docs.forEach((element) {
      tempList.add(element.data());
    });

    setState(() {
      items = tempList;
      isLoaded = true;
    });
  }

  _showDeleteOptions(String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete User'),
              onTap: () {
                _deleteUser(userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _deleteUser(String userId) async {
    await collection.doc(userId).delete();
    // You may also want to perform additional cleanup or actions after deletion
    _fetchUserData(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Icon(Icons.search, color: Colors.white, size: 22)),
                  )
                ],
              ),
            ),
            Column(
              children: isLoaded
                  ? items.map((item) {
                return GestureDetector(
                  onTap: () {
                    _showDeleteOptions(item["uid"]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Icon(Icons.person, size: 50,),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item["uid"],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        )
                      ],
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