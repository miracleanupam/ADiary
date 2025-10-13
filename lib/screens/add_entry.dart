import 'dart:io';
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:adiary/services/images.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AddEntry extends StatefulWidget {
  final Function fn;

  const AddEntry({super.key, required this.fn});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  int? _entryId;
  DateTime? _selectedDate = DateTime.now();
  List<String> _pickedImages = [];
  String? _directory;

  final TextEditingController _journalController = TextEditingController();
  final EntryProvider entryProvider = EntryProvider();
  final ImageService imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _getImageDirectory();
  }

  void _getImageDirectory() async {
    Directory imageDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      _directory = imageDirectory.path;
    });
  }

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

  Future<void> _handleImagesSelection() async {
    List<String> pickedImages = await imageService.pickImages();

    setState(() {
      _pickedImages = [..._pickedImages, ...pickedImages];
    });
  }

  void _removePickedImage(index) async {
    String imageName = _pickedImages[index];
    String imagePath = "$_directory/$imageName";

    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  void _saveEntry() async {
    if (_selectedDate != null && _journalController.text.isNotEmpty) {
      Entry newEntry = Entry(
        content: _journalController.text,
        date: DateFormat.yMMMd().format(_selectedDate!),
        images: _pickedImages,
      );
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

  Widget _removableImage(index) {
    return Stack(children: [
      ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(6),
          child: Image.file(
            File("$_directory/${_pickedImages[index]}"),
            height: 100,
          )),
      Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => _removePickedImage(index),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close,
                    size: 16,
                  ),
                )),
          )),
    ]);
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8.0, 8, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(value: "Images"),
                  GestureDetector(
                    onTap: _handleImagesSelection,
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.pink.shade900,
                    ),
                  )
                ],
              ),
            ),
            if (_pickedImages.isNotEmpty)
              Stack(
                children: [
                  // Scrollable horizontal list
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          List.generate(_pickedImages.length * 2 - 1, (index) {
                        if (index.isEven) {
                          final itemIndex = index ~/ 2;
                          return _removableImage(itemIndex);
                        } else {
                          return const SizedBox(width: 12); // separator
                        }
                      }),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            AlevatedButton(
                onPressed: _saveEntry,
                icon: Icons.favorite_border,
                text: 'Save Memory'),
            SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}
