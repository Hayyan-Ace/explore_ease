import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package

class UserDetailWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onDeletePressed;
  final VoidCallback onSetAsGuidePressed;

  const UserDetailWidget({
    required this.userData,
    required this.onDeletePressed,
    required this.onSetAsGuidePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'User Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Username', userData["username"] ?? "not given"),
          _buildDetailRow('Email', userData["email"] ?? "not given"),
          _buildDetailRow('UID', userData["uid"]),
          _buildDetailRow('isAdmin', userData["isAdmin"]?.toString() ?? 'false'),
          // Add more fields as needed
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 20,
                  shadowColor: const Color(0xFFa2d19f),
                  backgroundColor: const Color(0xFFa2d19f).withOpacity(0.9),
                ),
                onPressed: () {
                  // Check if the user is already a tour guide
                  if (userData["isGuide"] == true) {
                    Fluttertoast.showToast(
                      msg: "User is already a tour guide!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    // Call the onSetAsGuidePressed callback
                    onSetAsGuidePressed();
                    // Set isGuide to true and assignedTour to an empty string
                    userData["isGuide"] = true;
                    userData["assignedTour"] = ""; // Set assignedTour to an empty string
                    // Show toast message
                    Fluttertoast.showToast(
                      msg: "User set as tour guide!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: const Text(
                  'Set as Tour Guide',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(width: 16), // Add space between buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 20,
                  shadowColor: const Color(0xFFa2d19f),
                  backgroundColor: Colors.red, // Change color to red
                ),
                onPressed: () {
                  onDeletePressed();
                  Fluttertoast.showToast( // Show toast when user is deleted
                    msg: "User Deleted",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: const Text(
                  'Delete User',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
