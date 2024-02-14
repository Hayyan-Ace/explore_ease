import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Create_Tour_Page.dart';
import 'Edit_Tour_Page.dart';

class AdminToursPage extends StatefulWidget {
  const AdminToursPage({Key? key}) : super(key: key);

  @override
  State<AdminToursPage> createState() => _AdminToursPageState();
}

class _AdminToursPageState extends State<AdminToursPage> {
  var collection = FirebaseFirestore.instance.collection("Tour");
  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  String? uid; // Make sure to initialize or set the uid value accordingly



  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection("users");

  late List<Map<String, dynamic>> items = [];
  bool isLoaded = false;
  late TextEditingController searchController;

  // Add a GlobalKey for the RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  void _editTourDetails(Map<String, dynamic> tourDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTourPage(tourDetails: tourDetails),
      ),
    );
  }

  void _createTour() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTourPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchTourData();
    searchController = TextEditingController();
  }

  Future<void> _fetchTourData() async {
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

  Future<void> _searchTours(String query) async {
    if (query.isEmpty) {
      // If the search query is empty, reload the original data
      await _fetchTourData();
    } else {
      // Implement tour search logic based on your requirements
      // For now, let's filter tours based on the tourName
      List<Map<String, dynamic>> filteredList = items
          .where((tour) =>
          tour["tourName"].toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        items = filteredList;
      });
    }
  }


  // Implement the refresh logic
  Future<void> _handleRefresh() async {
    await _fetchTourData();
  }

  Future<void> _assignTourGuide(String tourId) async {
    // Check if a tour guide is already assigned to this tour
    var tourDoc = await collection.doc(tourId).get();
    var tourData = tourDoc.data();
    if (tourData != null && tourData.containsKey("tourGuide") && tourData["tourGuide"] != "") {
      // If a tour guide is already assigned, show a message and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("A tour guide is already assigned to this tour.")),
      );
      return;
    }

    List<Map<String, dynamic>> guides = [];

    // Fetch list of users where isGuide is true and assignedTour is empty
    var usersSnapshot = await _userCollection.where("isGuide", isEqualTo: true)
        .where("assignedTour", isEqualTo: "")
        .get();

    usersSnapshot.docs.forEach((userDoc) {
      var userData = userDoc.data();
      if (userData is Map<String, dynamic>) {
        guides.add(userData);
      }
    });

    // Show dialog to choose a tour guide
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (guides.isNotEmpty) {
          return AlertDialog(
            title: Text('Assign Tour Guide'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(guides[index]["username"]),
                    onTap: () {
                      _assignTourGuideToTour(tourId, guides[index]);
                    },
                  );
                },
              ),
            ),
          );
        } else {
          return AlertDialog(
            title: Text('No Guides Available'),
            content: Text('There are no available tour guides.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _assignTourGuideToTour(String tourId, Map<String, dynamic> guide) async {
    String tourGuideUid = guide["uid"]; // Assuming "uid" is the key for the UID in the guide map
    String tourName = items.firstWhere((tour) => tour["tourId"] == tourId)["tourName"];

    // Check if a tour guide is already assigned to this tour
    var tourDoc = await collection.doc(tourId).get();
    var tourData = tourDoc.data() as Map<String, dynamic>; // Explicit cast to Map<String, dynamic>
    if (tourData != null && tourData.containsKey("tourGuide") && tourData["tourGuide"] != "") {
      // If a tour guide is already assigned, show a message and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("A tour guide is already assigned to this tour.")),
      );
      return;
    }

    // Update the assignedTour field in the users collection for the tour guide
    await _userCollection.doc(tourGuideUid).update({"assignedTour": tourName});

    // Update the tour document with the tour guide UID
    await collection.doc(tourId).update({
      "tourGuide": tourGuideUid,
    });

    // Create a chat group for the tour
    String groupName = "Tour_$tourName";
    await _createGroup(guide["username"], tourGuideUid, groupName);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tour guide assigned successfully!")),
    );
  }





  Future<void> _createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "activeStatus":false,
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }


  // Show the delete confirmation dialog
  Future<void> _showDeleteDialog(String tourId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Tour'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this tour?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteTour(tourId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Delete the tour from Firebase
  Future<void> _deleteTour(String tourId) async {
    await collection.doc(tourId).delete();
    // Refresh the tour data after deletion
    await _fetchTourData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOURS',
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Total Tours: ${items.length}',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    onChanged: (query) => _searchTours(query),
                    decoration: InputDecoration(
                      hintText: 'Search Tours',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFa2d19f),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.search, color: Colors.black, size: 22),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: isLoaded
                  ? RefreshIndicator(
                color: const Color(0xFFa2d19f),
                // Set the GlobalKey
                key: _refreshIndicatorKey,
                // Set the onRefresh callback
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFa2d19f), // Set to your desired background color
                          child: Icon(Icons.location_pin),
                        ),
                        title: Row(
                          children: [
                            Text(
                              items[index]["tourName"] ?? "Not Given",
                              style: Theme.of(context).textTheme.headline6?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          items[index]["description"] ?? "",
                          style:
                          Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),
                          maxLines: 5,
                        ),
                        trailing: PopupMenuButton<String>(
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTourDetails(items[index]);
                            } else if (value == 'delete') {
                              _showDeleteDialog(items[index]["tourId"]);
                            } else if (value == 'assign_guide') {
                              // Add logic to assign a tour guide
                              _assignTourGuide(items[index]["tourId"]);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit Tour'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete Tour'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'assign_guide',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Assign Tour Guide'),
                              ),
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(16), // Adjust padding as needed
                      ),
                    );
                  },
                ),
              )
                  : const CircularProgressIndicator(
                color: Color(0xFFa2d19f),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTour,
        tooltip: 'Create Tour',
        backgroundColor: const Color(0xFFa2d19f),
        child: const Icon(Icons.add),
      ),
    );
  }
}
