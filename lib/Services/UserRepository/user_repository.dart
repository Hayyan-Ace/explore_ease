import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Models/User/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Map<String, dynamic> userData;

  Future<MyAppUser?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        // Map Firestore data to your MyAppUser model
        userData = userDoc.data() as Map<String, dynamic>;
        return MyAppUser.fromMap(userData);
      }
      return null;
    } catch (e) {
      // Handle any potential errors
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<String?> getTourUid() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    // Check if user data exists and contains bookings
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    if (userData != null && userData.containsKey('bookings')) {
      List<dynamic> bookings = userData['bookings'];

      // Assuming you want to get the tourUid from the first booking (index 0)
      if (bookings.isNotEmpty) {
        Map<String, dynamic> firstBooking = bookings[0];
        Fluttertoast.showToast(
          msg: firstBooking.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
        );
        if (firstBooking.containsKey('tourUid')) {
          String tourUid = firstBooking['tourUid'];

          return tourUid;
        }
      }
    }
  }
}