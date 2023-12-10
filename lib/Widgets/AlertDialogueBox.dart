import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget{
  final String text1;
  final String text2;
  AlertBox ({Key? key, required this.text1, required this.text2}) : super(key : key);


  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text(text1),
      content: Text(text2),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    );
  }
}