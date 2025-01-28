import 'package:flutter/material.dart';

class AlevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;

  const AlevatedButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade200,
            foregroundColor: Colors.pink.shade900,
            iconColor: Colors.pink.shade900,
            iconSize: 24,
            textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'IndieFlower')),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(
              width: 5,
            ),
            Text(text),
          ],
        ));
  }
}
