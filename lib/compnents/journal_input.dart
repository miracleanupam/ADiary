import 'package:flutter/material.dart';

class JournalInput extends StatelessWidget {
  const JournalInput({
    super.key,
    required this.journalController,
  });

  final TextEditingController journalController;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: journalController,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          labelText: "What made you happy?",
          border: OutlineInputBorder(),
        ),
        style: TextStyle(
          fontSize: 24,
        ),
        maxLines: null,
        expands: true,
      );
  }
}