import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final Function fn;
  final DateTime? selectedDate;

  const DatePicker({super.key, required this.fn, this.selectedDate});

  static final _style = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    textStyle: const TextStyle(
      fontSize: 24,
      fontFamily: 'IndieFlower',
      fontWeight: FontWeight.bold,
    ),
  );

  String get _label => selectedDate == null
      ? 'Pick a Date'
      : DateFormat.yMMMd().format(selectedDate!);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => fn(),
      icon: const Icon(Icons.calendar_month),
      style: _style,
      label: Text(_label),
    );
  }
}