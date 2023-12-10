import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';

class EmailVerificationController extends GetxController {
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    sendVerificationEmail();
    setTimeForAutoRedirect();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await AuthenticationRepository.instance.sendVerificationEmail();
    } catch (e) {
      String errorMessage = 'Error email verification: $e';
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      );
    }
  }

  Future<void> setTimeForAutoRedirect() async{
    _timer  = Timer.periodic(const Duration(seconds: 3), (timer) async {
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user!.emailVerified){
        timer.cancel();
        // await AuthenticationRepository.instance.createUserInFirestore();        Fluttertoast.showToast(
        //   msg: "Email Verified! Logging In.",
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.TOP,);
        AuthenticationRepository.instance.setInitialScreen(user);
      }

    });
  }

}