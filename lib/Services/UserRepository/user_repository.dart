import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/User/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MyAppUser?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Map Firestore data to your MyAppUser model
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return MyAppUser.fromMap(userData);
      }
      return null;
    } catch (e) {
      // Handle any potential errors
      print('Error fetching user details: $e');
      return null;
    }
  }
}
