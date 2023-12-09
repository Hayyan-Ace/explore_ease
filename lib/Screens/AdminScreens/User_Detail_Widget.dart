import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserDetailWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onDeletePressed;

  const UserDetailWidget({
    required this.userData,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
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
          ElevatedButton(
            onPressed: onDeletePressed,
            child: Text('Delete User'),
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
            style: TextStyle(
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
