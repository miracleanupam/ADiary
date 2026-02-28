import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class JournalInput extends StatelessWidget {
  final TextEditingController journalController;

  const JournalInput({super.key, required this.journalController});

  static final _borderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: PinkColors.shade900),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: journalController,
      textAlignVertical: TextAlignVertical.top,
      maxLines: null,
      expands: true,
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
        labelText: 'What made you happy?',
        labelStyle: TextStyle(color: PinkColors.shade900),
        enabledBorder: _borderStyle,
        focusedBorder: _borderStyle,
      ),
    );
  }
}