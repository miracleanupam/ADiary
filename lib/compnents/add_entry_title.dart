import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class AddEntryTitle extends StatelessWidget {
  const AddEntryTitle({super.key});

  static final _blossomStyle = TextStyle(
    shadows: [
      Shadow(
        color: PinkColors.shade900,
        blurRadius: 10,
        offset: Offset.zero,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '🌸🌸 ', style: _blossomStyle),
        const TextSpan(text: 'Recording Happiness...'),
        TextSpan(text: ' 🌸🌸', style: _blossomStyle),
        TextSpan(text: '  ')
      ])),
    );
  }
}
