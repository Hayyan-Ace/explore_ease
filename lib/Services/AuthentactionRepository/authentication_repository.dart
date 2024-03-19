import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Screens/AdminScreens/admin_main_page.dart';
import 'package:travel_ease_fyp/Screens/EmailVerification/email_verification.dart';
import 'package:travel_ease_fyp/Screens/GuideScreens/guide_main_page.dart';
import 'package:travel_ease_fyp/Screens/LoginPage/login_screen.dart';

import '../../Models/User/user_model.dart';
import '../../Screens/UserScreens/user_main_page.dart';
import '../../Screens/IntroScreens/welcome.dart';
import '../UserRepository/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  MyAppUser? currentuser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Rx<User?> firebaseUser;
  int checkForInitialStateFunc = 0;
  late String _email;
  late String _username;
  late String _password;
  late String _fullName;
  late String _cnic;
  late String _phoneNo;

  // Define the users collection
  late CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    setInitialScreen(firebaseUser.value);
  }


  Future<void> setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => const WelcomeScreen());
      return; // Exit early if no user
    }

    currentuser = await UserRepository().getUserDetails(user.uid);

    if (currentuser!.isAdmin) {
      Get.offAll(() => const AdminPanelMain());
    } else if (currentuser!.isGuide) {
      Get.offAll(() => const GuidePanelMain());
    } else if (user.emailVerified) {
      Get.offAll(() => const UserMainPage());
    } else {
      Get.offAll(() => const EmailVerificationScreen());
    }
  }


  Future<void> createUserInFirestore() async {
    // Create user document in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.value!.uid)
        .set({
      'uid': firebaseUser.value!.uid,
      'email': _email,
      'username': _username,
      'fullName': _fullName,
      'cnic': _cnic,
      'phoneNo': _phoneNo,
      'profilePicture': '', // Default or null, update as needed
      'isAdmin': false,
      'isGuide': false,// Default to false, update as needed
    });
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
    String fullName,
    String cnic,
    String phoneNo,
  ) async {
    _email = email;
    _username = username;
    _cnic = cnic;
    _fullName = fullName;
    _password = password;
    _phoneNo = phoneNo;

    try {
      // Check if username is unique
      bool isUsernameUniqueResult = await isUsernameUnique(username);
      if (!isUsernameUniqueResult) {
        Fluttertoast.showToast(
          msg: 'Username is already taken.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
        );
        return;
      }

      // Email and username are unique, proceed with user creation
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebaseUser.value!.reload();

      if (checkForInitialStateFunc == 0) {
        checkForInitialStateFunc = 1;
        if (firebaseUser.value != null) {
          Get.offAll(() => const EmailVerificationScreen());
        } else {
          Get.offAll(() => const UserMainPage());
        }
      } else {

        setInitialScreen(firebaseUser.value);
      }


    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error sign-up service: $e';

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      currentuser =
          await UserRepository().getUserDetails(_auth.currentUser!.uid);
      if (currentuser?.isAdmin == true) {
        Get.offAll(() => const AdminPanelMain());
      } else if (currentuser!.isGuide) {
        Get.offAll(() => const GuidePanelMain());
      }
      else {
        Get.offAll(() => const UserMainPage());
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error during login: $e';

      if (e.code == 'user-not-found') {
        errorMessage = 'User not found. Please check your email or sign up.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email syntax.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage =
            'An internal error has occurred. [ INVALID_LOGIN_CREDENTIALS ]';
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
    Get.offAll(() => const LoginScreen());
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error sending verification email: $e';
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );
    }
  }

// Function to check if the email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      // Check if username exists in Firestore 'users' collection
      var snapshot =
          await _usersCollection.where('username', isEqualTo: username).get();

      // If no documents are found, the username is unique
      return true;
    } catch (e) {
      // Handle Firestore query error if needed
      throw e;
    }
  }
}
