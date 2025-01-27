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
            textStyle: TextStyle(
                fontFamily: 'IndieFlower', fontWeight: FontWeight.bold)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18,),
            SizedBox(width: 5,),
            Text(text, style: TextStyle(fontSize: 18),),
          ],
        ));
  }
}
