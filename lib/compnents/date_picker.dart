import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final Function fn;
  final DateTime? selectedDate;
  const DatePicker({super.key, required this.fn, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () => fn(),
        icon: const Icon(Icons.calendar_month),
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
                fontSize: 24,
                fontFamily: 'IndieFlower',
                fontWeight: FontWeight.bold)),
        label: Text(
          selectedDate == null
              ? "Pick a Date"
              : DateFormat.yMMMd().format(selectedDate!),
        ));
  }
}
