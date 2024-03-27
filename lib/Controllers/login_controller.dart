import 'package:get/get.dart';
import 'package:travel_ease_fyp/Services/AuthentactionRepository/authentication_repository.dart';

class LoginController extends GetxController{
  static LoginController get instance => Get.find();

  void loginUser(String email, String password){
    AuthenticationRepository.instance.loginWithEmailAndPassword(email, password);
  }


}