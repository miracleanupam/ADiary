import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final Function fn;
  final Map<String, dynamic>? mood;
  const MoodPicker({super.key, required this.fn, this.mood});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
        onPressed: () => fn(),
        icon: mood?['icon'] ?? Icon(Icons.sentiment_satisfied_alt),
        label: Text(
          mood?['label'] ?? "Pick Mood",
          style: TextStyle(
              fontSize: 16,
              fontFamily: "IndieFlower",
              fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
            backgroundColor: mood?['color'] ?? Colors.teal));
  }
}
