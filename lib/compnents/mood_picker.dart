import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final Function fn;
  final Map<String, dynamic>? mood;
  final Function clearMood;
  const MoodPicker({super.key, required this.fn, this.mood, required this.clearMood});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MoodPill(fn: fn, mood: mood),
        if (mood != null)
        Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => clearMood(),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withValues(alpha: 1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.pink.shade900,
                    ),
                  )),
            ))
      ],
    );
  }
}

class MoodPill extends StatelessWidget {
  const MoodPill({
    super.key,
    required this.fn,
    required this.mood,
  });

  final Function fn;
  final Map<String, dynamic>? mood;

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
          backgroundColor: mood?['bgColor'] ?? Colors.pink.shade100,
          side: BorderSide(
              color: mood?['borderColor'] ?? Colors.pink.shade900),
          foregroundColor: mood?['textColor'] ?? Colors.pink.shade900,
        ));
  }
}
