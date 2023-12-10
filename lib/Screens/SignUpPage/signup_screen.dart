import 'package:flutter/material.dart';
import '../../Services/AuthentactionRepository/authentication_repository.dart';
import '../LoginPage/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late Color myColor;
  late Size mediaSize;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    myColor = Color(0xFFa2d19f);
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: const AssetImage("images/login_bg_img.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(myColor.withOpacity(0.5), BlendMode.dstATop),
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
            "images/logo.png",
            height: 300,
            width: 300,
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
        elevation: 8.0,
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
          'Welcome',
          style: TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.w500),
        ),
        _buildGreyText('Please sign up with your information'),
        const SizedBox(height: 60),
        _buildGreyText('Email address'),
        _buildInputField(_emailController),
        const SizedBox(height: 40),
        _buildGreyText('Password'),
        _buildInputField(_passwordController, isPassword: true),
        const SizedBox(height: 20),
        _buildGreyText('Confirm Password'),
        _buildInputField(_confirmPasswordController, isPassword: true),
        const SizedBox(height: 20),
        _buildGreyText('Username'),
        _buildInputField(_userNameController),
        const SizedBox(height: 20),
        _buildSignUpButton(),
        const SizedBox(height: 10),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller, {isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword ? const Icon(Icons.remove_red_eye) : const Icon(Icons.done),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await AuthenticationRepository.instance.signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _userNameController.text.trim(),
          );
        } catch (e) {
          // Handle sign up errors here (e.g., display an error message)
          print('Error during sign up: $e');
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
        'Sign Up',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        // Handle the "Already have an account? Log in here" action
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: const Text(
        'Already have an account? Log in here',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
