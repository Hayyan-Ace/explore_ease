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

  // Implement the refresh logic
  Future<void> _handleRefresh() async {
    await _fetchTourData();
  }

  // Show the delete confirmation dialog
  Future<void> _showDeleteDialog(String tourId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tour'),
          content: SingleChildScrollView(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
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
                    return Dismissible(
                      key: Key(items[index]["tourId"]),
                      onDismissed: (direction) {
                        _deleteTour(items[index]["tourId"]);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFFa2d19f),
                            child: Icon(Icons.location_pin),
                          ),
                          title: Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                items[index]["tourName"] ?? "Not Given",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            items[index]["description"] ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.copyWith(height: 1.5),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editTourDetails(items[index]);
                              } else if (value == 'delete') {
                                _showDeleteDialog(items[index]["tourId"]);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : const CircularProgressIndicator(color: Color(0xFFa2d19f),),
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
