import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';

class SignUpController extends GetxController{
  static SignUpController get instance => Get.find();


  void registerUser(String _email, String _password, String _username){
    AuthenticationRepository.instance.signUpWithEmailAndPassword(_email, _password, _username);

  }


}