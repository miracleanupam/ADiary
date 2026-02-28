import 'package:adiary/compnents/animated_close_button.dart';
import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final Function fn;
  final Map<String, dynamic>? mood;
  final Function clearMood;

  const MoodPicker({
    super.key,
    required this.fn,
    required this.clearMood,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MoodPill(fn: fn, mood: mood),
        if (mood != null)
          AnimatedCloseButton(top: 0, right: 0, fn: clearMood),
      ],
    );
  }
}

class MoodPill extends StatelessWidget {
  final Function fn;
  final Map<String, dynamic>? mood;

  const MoodPill({super.key, required this.fn, required this.mood});

  static const _labelStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'IndieFlower',
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => fn(),
      icon: mood?['icon'] ?? const Icon(Icons.sentiment_satisfied_alt),
      label: Text(mood?['label'] ?? '-- --', style: _labelStyle),
      style: FilledButton.styleFrom(
        backgroundColor: mood?['bgColor'] ?? PinkColors.shade100,
        side: BorderSide(color: mood?['borderColor'] ?? PinkColors.shade900),
        foregroundColor: mood?['textColor'] ?? PinkColors.shade900,
      ),
    );
  }
}