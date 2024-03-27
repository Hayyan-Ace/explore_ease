import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController? controller;
  final bool readOnly;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                decoration: InputDecoration(
                  labelText: label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

