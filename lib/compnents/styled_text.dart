import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String value;
  final double fontSize;
  final Color? color;

  const StyledText({
    super.key,
    required this.value,
    this.fontSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color ?? PinkColors.shade900,
        ),
      ),
    );
  }
}