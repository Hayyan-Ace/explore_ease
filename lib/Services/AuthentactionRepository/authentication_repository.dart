import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Screens/EmailVerification/email_verification.dart';
import 'package:travel_ease_fyp/Screens/LoginPage/login_screen.dart';
import 'package:travel_ease_fyp/Screens/Main/main_page.dart';

import '../../Models/User/user_model.dart';
import '../../Screens/intro_screens/welcome.dart';

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  int checkForInitialStateFunc = 0;

  @override
  void onReady() {
    firebaseUser =  Rx<User?> (_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    setInitialScreen(firebaseUser.value);

  }


  setInitialScreen (User? user) {
    user == null ? Get.offAll(() => const WelcomeScreen()): user.emailVerified ? Get.offAll(() => const MainPage()) : Get.offAll(() => EmailVerificationScreen());
  }



  /*------------------login and sign up--------------------*/
  Future<MyAppUser?> signUpWithEmailAndPassword(String email, String password, String username) async {

    _auth.isSignInWithEmailLink(email);
    try {

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser.value!.reload();

      if (checkForInitialStateFunc == 0) {
        checkForInitialStateFunc = 1;
        if (firebaseUser.value != null) {
          Get.offAll(() => EmailVerificationScreen());
        } else {
          Get.offAll(() => const MainPage());
        }
      }else{
        setInitialScreen(firebaseUser.value);
      }

      Fluttertoast.showToast(msg: 'User signed up: ${firebaseUser.value!.email}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );


      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.value!.uid).set({
        'uid': firebaseUser.value!.uid,
        'email': email,
        'username': username,
        'profilePicture': '', // Default or null, update as needed
        'isAdmin': false, // Default to false, update as needed
      });


      return MyAppUser(
        uid: firebaseUser.value!.uid,
        email: email,
        username: username,
        profilePicture: '',
        isAdmin: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error sign-up service: $e';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email')
        errorMessage = 'The email address is not valid';


      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );

    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password,) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAll(MainPage());


    } on FirebaseAuthException catch (e) {

      String errorMessage = 'Error during login: $e';

      if (e.code == 'user-not-found') {
        errorMessage = 'User not found. Please check your email or sign up.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email syntax.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = 'An internal error has occurred. [ INVALID_LOGIN_CREDENTIALS ]';
      }
      Fluttertoast.showToast(msg: errorMessage);
    }
  }

  Future<void> logOut() async{
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

/*------------------email verification--------------------*/

  Future<void> sendVerificationEmail() async{
    try {
      await _auth.currentUser?.sendEmailVerification();

    } on FirebaseAuthException catch(e){
        String errorMessage = 'Error email verification: $e';
        Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,);
    }

  }



}