import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'booking_dialoguebox.dart';

class TourDetailsPage extends StatelessWidget {
  final String tourID;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TourDetailsPage({super.key, required this.tourID});
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Tour').doc(tourID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tour details not available'));
          } else {
            var tourData = snapshot.data!.data() as Map<String, dynamic>?;

            if (tourData == null) {
              return const Center(child: Text('Tour details not available'));
            }

            return _buildTourDetails(context, tourData);
          }
        },
      ),
    );
  }

  Widget _buildTourDetails(
      BuildContext context, Map<String, dynamic> tourData) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            tourData['imageUrl'],
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(bottom: 0, child: _buildBottom(context, tourData)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom(BuildContext context, Map<String, dynamic> tourData) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(context, tourData),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Map<String, dynamic> tourData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            tourData['tourName'] ?? 'Tour Name Not Available',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildDescriptionBox(context, tourData['description'] ?? ''),
        if (tourData['tourDate'] != null)
          _buildDetailRow("Tour Date", _formatTourDate(tourData['tourDate'])),
        _buildDetailRow(
            "Duration", "${tourData['duration'] ?? 'Not Available'} days"),
        _buildDetailRow(
            "Departure Location", tourData['startingPoint'] ?? 'Not Available'),
        _buildDetailRow("Destination", tourData['endPoint'] ?? 'Not Available'),
        _buildDetailRow(
            "Price", "${tourData['price'] ?? 'Not Available'} Rupees"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _showPaymentOptionsDialog(context, tourData);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: const Color(0xFFa2d19f),
            minimumSize: const Size.fromHeight(60),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(BuildContext context, String description) {
    return GestureDetector(
      onTap: () =>
          _showDescriptionPopup(context, _formatDescription(description)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _formatDescription(description),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _showDescriptionPopup(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Tour Description"),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  String _formatDescription(String description) {
    List<String> parts = description.split(RegExp(r'(?=Day \d+:)'));
    String formattedDescription = parts.map((part) => '\n$part\n').join();
    return formattedDescription.trim();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> makePayment(BuildContext context, double price,Map<String, dynamic> tourData) async {
    try {
      paymentIntentData = await createPaymentIntent(calculateAmount(price.toString()), 'PKR');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'ExploreEase',
        ),
      );
      displayPaymentSheet(context, tourData);
      _confirmTourStripe(tourData);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }


  Future<void> _confirmTourStripe(Map<String, dynamic> tourData) async {
    // Update user's database with booking information
    await FirebaseFirestore.instance.collection('users').doc(
        _auth.currentUser!.uid).update({
      'bookings': FieldValue.arrayUnion([
        {
          'tourName': tourData['tourName'],
          'tourUid': tourID,
          'verified': true,
        }
      ]),
    });
  }

      Future<void> displayPaymentSheet(BuildContext context,Map<String, dynamic> tourData) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment successful')));

      paymentIntentData = null;
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error from Stripe: ${e.error.localizedMessage}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unforeseen error: $e')));
      }
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51PFI7YP7nb9HAUv5Evy1pPWjOb7ouYXPkEb9UMBIBPhaO47Cd3WltTVudrOmhkEXrh3zvMOMnnq1OPvIlE6jSmaa00OiclqWWH',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount) * 100).toInt().toString();
    return calculatedAmount;
  }


  String _formatTourDate(dynamic tourDate) {
    if (tourDate is Timestamp) {
      DateTime dateTime = tourDate.toDate();
      return DateFormat.yMMMd().format(dateTime);
    } else if (tourDate is DateTime) {
      return DateFormat.yMMMd().format(tourDate);
    } else {
      return 'Not Available';
    }
  }

  void _showPaymentOptionsDialog(BuildContext context, Map<String, dynamic> tourData) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null &&
        userData['bookings'] != null &&
        (userData['bookings'] as List).isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('You can only book one tour at a time.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Select Payment Method",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.payment, color: Colors.green[700]),
                    title: Text('Stripe Payment'),
                    onTap: () {
                      Navigator.pop(context);
                      double price = double.tryParse(tourData['price']) ?? 0.0;
                      makePayment(context, price, tourData);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.account_balance, color: Colors.green[700]),
                    title: Text('Bank Transfer'),
                    onTap: () {
                      Navigator.pop(context);
                      showBankTransferDetails(context, tourData);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[700],
                ),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  void showBankTransferDetails(BuildContext context, Map<String, dynamic> tourData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Bank Transfer Details",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.account_balance, color: Colors.green[700]),
                  title: Text('Bank Name: Dummy Bank'),
                  subtitle: Text('Account Number: 1234567890'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green[700]),
                  title: Text('Branch: Main Branch'),
                  subtitle: Text('Address: 123 Main Street, City'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showBookingDialog(context, tourData);

              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700],
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showBookingDialog(BuildContext context, Map<String, dynamic> tourData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingDialog(
          tourName: tourData['tourName'] ?? 'Tour Name Not Available',
          tourID: tourData['tourId'] ?? 'Tour ID Not Available',
          tourDate: '', // You need to set the tourDate accordingly
        );
      },
    );
  }

}
