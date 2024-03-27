import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget{
  final String text1;
  final String text2;
  const AlertBox ({super.key, required this.text1, required this.text2});


  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text(text1),
      content: Text(text2),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}