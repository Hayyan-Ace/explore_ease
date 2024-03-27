import 'package:flutter/material.dart';

class LargeBoldText extends StatelessWidget{
  double size ;
  final String text;
  final Color color;
  LargeBoldText ({super.key, required this.text, this.color = Colors.black87 , this.size = 30});


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