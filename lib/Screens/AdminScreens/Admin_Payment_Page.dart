import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPaymentPage extends StatefulWidget {
  const AdminPaymentPage({Key? key}) : super(key: key);

  @override
  State<AdminPaymentPage> createState() => _AdminPaymentPageState();
}

class _AdminPaymentPageState extends State<AdminPaymentPage> {
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

  Future<void> _handleRefresh() async {
    // You can perform any background tasks or fetch new data here
    await _fetchUserData();
  }

  Future<void> _showReceiptDialog(String receiptImageUrl, String userUid, int bookingIndex) async {
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
                onPressed: () async {
                  await updateVerificationStatus(userUid, bookingIndex);
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

  Future<void> updateVerificationStatus(String uid, int bookingIndex) async {
    var userReference = FirebaseFirestore.instance.collection('users').doc(uid);

    var currentBookings = (await userReference.get()).data()?['bookings'] as List<dynamic>?;

    if (currentBookings != null) {
      currentBookings[bookingIndex]['verified'] = true;

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

  @override
  Widget build(BuildContext context) {
    int unverifiedPaymentsCount = countUnverifiedPayments();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PAYMENTS',
              style: TextStyle(color: Colors.black, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              'Unverified Payments: $unverifiedPaymentsCount',
              style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: const Color(0xFFa2d19f),
          onRefresh: _handleRefresh,
          child: Center(
          child: isLoaded
            ? ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, userIndex) {
            List<dynamic>? bookings = items[userIndex]["bookings"];
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
                              String userUid = items[userIndex]["uid"] ?? '';

                              print("Receipt Image URL: $receiptImageUrl");

                              _showReceiptDialog(receiptImageUrl, userUid, bookingIndex);
                            } else {
                              print("Error: 'tourUid' is not present in the booking data");
                            }
                          } else {
                            print("Error: Booking data is null or not a Map");
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items[userIndex]["username"] ?? "Username not available",
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
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.more_vert),
                          ),
                        ),
                      ),
                ],
              );
            } else {
              return Container();
            }
          },
        )
            : CircularProgressIndicator(color: Color(0xFFa2d19f),),
          ),
      ),
    );
  }
}
