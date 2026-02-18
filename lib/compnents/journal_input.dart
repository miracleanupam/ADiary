import 'package:flutter/material.dart';

class JournalInput extends StatelessWidget {
  const JournalInput({
    super.key,
    required this.journalController,
  });

  final TextEditingController journalController;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borderStyle = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink.shade900, width: 1));

    return TextField(
      controller: journalController,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
          labelText: "What made you happy?",
          enabledBorder: borderStyle,
          focusedBorder: borderStyle,
          labelStyle: TextStyle(color: Colors.pink.shade900)),
      style: TextStyle(
        fontSize: 24,
      ),
      maxLines: null,
      expands: true,
    );
  }
}
