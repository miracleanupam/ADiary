import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEntry extends StatefulWidget {
  final Function fn;

  const AddEntry({super.key, required this.fn});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  int? _entryId;
  DateTime? _selectedDate = DateTime.now();
  final TextEditingController _journalController = TextEditingController();
  final EntryProvider entryProvider = EntryProvider();

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveEntry() async {
    if (_selectedDate != null && _journalController.text.isNotEmpty) {
      Entry newEntry = Entry(
          content: _journalController.text,
          date: DateFormat.yMMMd().format(_selectedDate!));
      if (_entryId != null) {
        newEntry.id = _entryId;
      }

      Entry updatedEntry = await entryProvider.upsert(newEntry);

      setState(() {
        _entryId = updatedEntry.id;
      });
      await widget.fn();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Memory Preserved!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a date and write an entry.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text.rich(TextSpan(children: [
          TextSpan(
              text: '🌸🌸',
              style: TextStyle(shadows: [
                Shadow(
                    color: Colors.pink.shade900,
                    blurRadius: 10,
                    offset: Offset(0, 0))
              ])),
          TextSpan(text: ' Recording Happiness... '),
          TextSpan(
              text: '🌸🌸',
              style: TextStyle(shadows: [
                Shadow(
                    color: Colors.pink.shade900,
                    blurRadius: 10,
                    offset: Offset(0, 0))
              ]))
        ])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
                onPressed: () => _pickDate(context),
                icon: const Icon(Icons.calendar_month),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(
                        fontSize: 24,
                        fontFamily: 'IndieFlower',
                        fontWeight: FontWeight.bold)),
                label: Text(
                  _selectedDate == null
                      ? "Pick a Date"
                      : DateFormat.yMMMd().format(_selectedDate!),
                )),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _journalController,
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
              ),
            ),
            SizedBox(height: 16),
            AlevatedButton(
                onPressed: _saveEntry,
                icon: Icons.favorite_border,
                text: 'Save Memory')
          ],
        ),
      ),
    );
  }
}
