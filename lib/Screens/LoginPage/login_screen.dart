import 'package:flutter/material.dart';
import '../../Services/AuthentactionRepository/authentication_repository.dart';
import '../../Services/ChatRepository/alert_service.dart';
import '../SignUpPage/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Color myColor;
  late Size mediaSize;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberUser = false;
  bool isPasswordVisible = false;
  final AlertService _alertService = AlertService(); // Instance of AlertService

  @override
  Widget build(BuildContext context) {
    myColor = const Color(0xFFa2d19f);
    mediaSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: const AssetImage("images/login_bg_img.jpg"),
          fit: BoxFit.cover,
          colorFilter:
          ColorFilter.mode(myColor.withOpacity(0.5), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(top: 20, child: _buildTop()),
            Positioned(bottom: 0, child: _buildBottom()),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/logo.png", // Provide the correct path to your logo image
            height: 300, // Adjust the height as needed
            width: 300, // Adjust the width as needed
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.w500),
        ),
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 60),
        _buildGreyText("Email address"),
        _buildInputField(_emailController),
        const SizedBox(height: 40),
        _buildGreyText("Password"),
        _buildInputField(_passwordController, isPassword: true),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        const SizedBox(height: 20),
        _buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        )
            : const SizedBox.shrink(),
      ),
      obscureText: isPassword && !isPasswordVisible,
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
          ),
          child: const Text("Don't have an account? Sign up here"),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Request permission and get token upon login
          _alertService.requestPermission();
          _alertService.getToken();

          // Proceed with login
          await AuthenticationRepository.instance.loginWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } catch (e) {
          // Handle login errors here (e.g., display an error message)
          print("Error during login: $e");
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        backgroundColor: myColor.withOpacity(0.9),
        minimumSize: const Size.fromHeight(60),
      ),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }
}
