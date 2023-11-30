import 'package:flutter/material.dart';

class LargeBoldText extends StatelessWidget{
  double size ;
  final String text;
  final Color color;
  LargeBoldText ({Key? key, required this.text, this.color = Colors.black87 , this.size = 30}) : super(key : key);


  @override
  Widget build(BuildContext context){
    return Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
      )
    );
  }
}