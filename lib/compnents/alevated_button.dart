import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class AlevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;

  const AlevatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  static final _style = ElevatedButton.styleFrom(
    backgroundColor: PinkColors.shade200,
    foregroundColor: PinkColors.shade900,
    iconColor: PinkColors.shade900,
    iconSize: 24,
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'IndieFlower',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
