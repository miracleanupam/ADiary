import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String value;
  
  const StyledText({super.key, required this.value});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}