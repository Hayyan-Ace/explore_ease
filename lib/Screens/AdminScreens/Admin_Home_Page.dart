import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Color myColor;
  int totalUsersCount = 0;
  int totalUnverifiedPaymentsCount = 0;
  int totalActiveToursCount = 0;

  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items;
  bool isLoaded = false;

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

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      QuerySnapshot usersSnapshot = await usersCollection.get();

      setState(() {
        totalUsersCount = usersSnapshot.size;
      });

      // Fetch user data before counting unverified payments
      await _fetchUserData();

      // Count unverified payments by iterating through user data
      int unverifiedPaymentsCount = 0;
      for (var user in items) {
        List<dynamic>? bookings = user["bookings"];
        if (bookings != null && bookings.isNotEmpty) {
          for (var booking in bookings) {
            if (booking != null && booking is Map<String, dynamic> && !booking['verified']) {
              unverifiedPaymentsCount++;
            }
          }
        }
      }

      setState(() {
        totalUnverifiedPaymentsCount = unverifiedPaymentsCount;
      });

      CollectionReference activeToursCollection = FirebaseFirestore.instance.collection('Tour');
      QuerySnapshot activeToursSnapshot = await activeToursCollection.get();

      setState(() {
        totalActiveToursCount = activeToursSnapshot.size;
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  Future<void> _handleRefresh() async {
    // You can perform any background tasks or fetch new data here
    await _fetchCounts();
  }

  @override
  Widget build(BuildContext context) {
    myColor = const Color(0xFFa2d19f);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DASHBOARD',
                style: TextStyle(
                  color: Colors.black87,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoCard('Total Users', totalUsersCount, Icons.person, Colors.blueAccent, Colors.blue),
                _buildInfoCard('Unverified Payments', totalUnverifiedPaymentsCount, Icons.payment_rounded, Colors.deepOrange, Colors.orange),
                _buildInfoCard('Active Tours', totalActiveToursCount, Icons.tour_outlined, Colors.green, Colors.lightGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, int count, IconData iconData, Color startColor, Color endColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 350,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5,),
              Icon(
                iconData,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
