import 'package:flutter/material.dart';

class AddEntryTitle extends StatelessWidget {
  const AddEntryTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(
          text: '🌸🌸 ',
          style: TextStyle(shadows: [
            Shadow(
                color: Colors.pink.shade900,
                blurRadius: 10,
                offset: Offset(0, 0))
          ])),
      TextSpan(text: 'Recording Happiness...'),
      TextSpan(
          text: ' 🌸🌸',
          style: TextStyle(shadows: [
            Shadow(
                color: Colors.pink.shade900,
                blurRadius: 10,
                offset: Offset(0, 0))
          ]))
    ]));
  }
}
