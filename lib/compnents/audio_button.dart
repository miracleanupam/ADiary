import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class AudioButton extends StatelessWidget {
  final bool showRecorder;
  final Function fn;

  const AudioButton({
    super.key,
    required this.showRecorder,
    required this.fn,
  });

  static final _style = ElevatedButton.styleFrom(
    side: BorderSide(color: PinkColors.shade900),
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
      onPressed: () => fn(),
      style: _style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(showRecorder ? Icons.edit_outlined : Icons.mic_none_outlined),
          const SizedBox(width: 5),
          Text(showRecorder ? 'Edit journal' : 'Take Me to Audio'),
        ],
      ),
    );
  }
}