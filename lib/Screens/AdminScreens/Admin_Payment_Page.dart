import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPaymentPage extends StatefulWidget {
  const AdminPaymentPage({Key? key}) : super(key: key);

  @override
  State<AdminPaymentPage> createState() => _AdminPaymentPageState();
}

class _AdminPaymentPageState extends State<AdminPaymentPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items;
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

  Future<void> _showReceiptDialog(String receiptImageUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Receipt Image'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(receiptImageUrl),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add code to update the 'verified' status in Firebase
                  // You can call a function here to update the status
                  Navigator.of(context).pop();
                },
                child: Text('Verify Payment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoaded
            ? ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, userIndex) {
            List<dynamic>? bookings = items[userIndex]["bookings"];
            if (bookings != null && bookings.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xff6ae792),
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      "Uid: ${items[userIndex]["uid"]}\nUsername: ${items[userIndex]["username"]}",
                    ),
                    trailing: Icon(Icons.more_vert),
                  ),
                  for (var bookingIndex = 0;
                  bookingIndex < bookings.length;
                  bookingIndex++)
                    if (bookings[bookingIndex] != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            dynamic booking = bookings[bookingIndex];
                            if (booking != null && booking is Map<String, dynamic>) {
                              // Check if 'tourUid' is present in the booking
                              if (booking.containsKey('tourUid')) {
                                String tourUid = booking['tourUid'];
                                // Use 'tourUid' as needed
                                print("Tour UID: $tourUid");

                                // You can now use 'tourUid' to retrieve the receipt image URL from your backend or any other source
                                String receiptImageUrl = booking['receiptImageUrl'] ?? '';
                                print("Receipt Image URL: $receiptImageUrl");

                                _showReceiptDialog(receiptImageUrl);
                              } else {
                                // Handle the case where 'tourUid' is not present
                                print("Error: 'tourUid' is not present in the booking data");
                              }
                            } else {
                              // Handle the case where 'booking' is null or not a Map
                              print("Error: Booking data is null or not a Map");
                            }
                          },

                          child: ListTile(
                            title: Text(
                              'Tour Name: ${bookings[bookingIndex]['tourName']},\nTour ID: ${bookings[bookingIndex]['tourUid']},\nVerified: ${bookings[bookingIndex]['verified']}\n - - - ',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Icon(Icons.more_vert),
                          ),
                        ),
                      ),
                ],
              );
            } else {
              return Container(); // Return an empty container if bookings is null or empty
            }
          },
        )
            : Text("No data"),
      ),
    );
  }
}
