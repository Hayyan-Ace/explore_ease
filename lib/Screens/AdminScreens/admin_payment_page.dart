import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Services/ChatRepository/chat_service.dart';

class AdminPaymentPage extends StatefulWidget {
  const AdminPaymentPage({Key? key}) : super(key: key);


  @override
  State<AdminPaymentPage> createState() => _AdminPaymentPageState();
}

class _AdminPaymentPageState extends State<AdminPaymentPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items = [];
  bool isLoaded = false;
  bool showVerifiedPayments = true;

  late String groupId; // Define groupId
  late String userName; // Define userName
  late String groupName; // Define groupName

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

  Future<void> _handleRefresh() async {
    await _fetchUserData();
  }

  Future<void> _showReceiptDialog(String receiptImageUrl, String userUid, int bookingIndex) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Receipt Image'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(receiptImageUrl),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFa2d19f),
                  ),
                  onPressed: () async {
                    await approvePayment(userUid, bookingIndex);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Verify Payment', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await disapprovePayment(userUid, bookingIndex);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Disapprove Payment', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> approvePayment(String uid, int bookingIndex) async {
    var userReference = FirebaseFirestore.instance.collection('users').doc(uid);
    var groupReference = FirebaseFirestore.instance.collection('groups');

    var currentBookings = (await userReference.get()).data()?['bookings'] as List<dynamic>?;
    if (currentBookings != null) {
      currentBookings[bookingIndex]['verified'] = true;

      await userReference.update({'bookings': currentBookings});

      // After verifying the payment, add the user to the respective tour group
      String tourName = currentBookings[bookingIndex]['tourName'];
      String userName = (await userReference.get()).data()?['username'];

      var querySnapshot = await groupReference.where('groupName', isEqualTo: 'Tour_$tourName').get();
      if (querySnapshot.docs.isNotEmpty) {
        String groupId = querySnapshot.docs.first.id; // assuming the first document holds the desired group
        await addGroupMember('Tour_$tourName', uid, userName, groupId);
      } else {
        print('Group not found for tour: $tourName');
      }
    }
  }

  Future<void> disapprovePayment(String uid, int bookingIndex) async {
    var userReference = FirebaseFirestore.instance.collection('users').doc(uid);

    var currentBookings = (await userReference.get()).data()?['bookings'] as List<dynamic>?;

    if (currentBookings != null) {
      currentBookings.removeAt(bookingIndex);

      // Update the 'bookings' field with the modified list
      await userReference.update({'bookings': currentBookings});
    }
  }


  int countUnverifiedPayments() {
    int count = 0;

    for (var user in items) {
      List<dynamic>? bookings = user["bookings"];
      if (bookings != null && bookings.isNotEmpty) {
        for (var booking in bookings) {
          if (booking != null && booking is Map<String, dynamic> && !booking['verified']) {
            count++;
          }
        }
      }
    }

    return count;
  }

  List<Map<String, dynamic>> getFilteredPayments() {
    if (showVerifiedPayments) {
      return items;
    } else {
      return items
          .where((user) => (user['bookings'] as List<dynamic>?)
          ?.any((booking) => booking is Map<String, dynamic> && !booking['verified']) ??
          false)
          .toList();
    }
  }

  Future<void> addGroupMember(String groupName, String uid, String userName, String groupId) async {
    DocumentReference groupDocRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

    // Update the group document to add the user as a member
    await groupDocRef.update({
      "members": FieldValue.arrayUnion(["$uid+$userName"]),
    });

    // Update the user's document to add the group
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userDocRef.update({
      "groups": FieldValue.arrayUnion(["$groupId+$groupName"]),
    });
  }


  @override
  Widget build(BuildContext context) {
    int unverifiedPaymentsCount = countUnverifiedPayments();
    List<Map<String, dynamic>> filteredPayments = getFilteredPayments();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PAYMENTS',
              style: TextStyle(color: Colors.black, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              'Unverified Payments: $unverifiedPaymentsCount',
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFa2d19f),
        onRefresh: _handleRefresh,
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Show/Hide\nVerified Payments", style: TextStyle(fontWeight: FontWeight.bold,),)),
                  Switch(
                    value: showVerifiedPayments,
                    onChanged: (value) {
                      setState(() {
                        showVerifiedPayments = value;
                      });
                    },
                    activeTrackColor: const Color(0xFFa2d19f),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  ),
                ],
              ),
              const Divider(thickness: 2, color: Color(0xFFa2d19f), indent: 10,endIndent: 10,),
              isLoaded
                  ? Expanded(
                child: ListView.builder(
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, userIndex) {
                    List<dynamic>? bookings = filteredPayments[userIndex]["bookings"];
                    if (bookings != null && bookings.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var bookingIndex = 0; bookingIndex < bookings.length; bookingIndex++)
                            if (bookings[bookingIndex] != null)
                              GestureDetector(
                                onTap: () {
                                  dynamic booking = bookings[bookingIndex];
                                  if (booking != null && booking is Map<String, dynamic>) {
                                    if (booking.containsKey('tourUid')) {
                                      String tourUid = booking['tourUid'];
                                      print("Tour UID: $tourUid");

                                      String receiptImageUrl = booking['receiptImageUrl'].toString();
                                      String userUid = filteredPayments[userIndex]["uid"] ?? '';

                                      print("Receipt Image URL: $receiptImageUrl");

                                      if (!booking['verified']) {
                                        _showReceiptDialog(receiptImageUrl, userUid, bookingIndex);
                                      }
                                    } else {
                                      print("Error: 'tourUid' is not present in the booking data");
                                    }
                                  } else {
                                    print("Error: Booking data is null or not a Map");
                                  }
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredPayments[userIndex]["username"] ?? "Username not available",
                                          style: Theme.of(context).textTheme.headline6?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Tour Name: ${bookings[bookingIndex]['tourName']}',
                                          style: Theme.of(context).textTheme.bodyText1,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Verified: ',
                                              style: Theme.of(context).textTheme.bodyText1,
                                            ),
                                            Icon(
                                              bookings[bookingIndex]['verified'] == true
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: bookings[bookingIndex]['verified'] == true
                                                  ? const Color(0xFFa2d19f)
                                                  : Colors.red,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              )
                  : const CircularProgressIndicator(color: Color(0xFFa2d19f)),
            ],
          ),
        ),
      ),
    );
  }
}
