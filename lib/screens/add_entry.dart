import 'dart:io';
import 'package:adiary/compnents/audio_button.dart';
import 'package:adiary/compnents/audio_input.dart';
import 'package:adiary/compnents/add_entry_title.dart';
import 'package:adiary/compnents/date_picker.dart';
import 'package:adiary/compnents/images_input.dart';
import 'package:adiary/compnents/journal_input.dart';
import 'package:adiary/compnents/mood_picker.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/services/images.dart';
import 'package:adiary/services/recording.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adiary/constants.dart' as constants;

class AddEntry extends StatefulWidget {
  final Function fn;

  const AddEntry({super.key, required this.fn});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  int? _entryId;
  DateTime? _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedMood;
  List<String> _pickedImages = [];
  String? _directory;

  final TextEditingController _journalController = TextEditingController();
  final EntryProvider entryProvider = EntryProvider();
  final ImageService imageService = ImageService();
  final RecorderService recorderService = RecorderService();
  bool _showRecorder = false;
  bool _isRecording = false;
  String _recordingPath = '';

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

  Future<Map<String, dynamic>?> showStringPicker(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vibe it! Pretty Lady!'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: constants.MOOD_OPTIONS
              .map((opt) => ChoiceChip(
                    avatar: opt['icon'],
                    label: Text(opt['label']),
                    backgroundColor: opt['bgColor'],
                    side: BorderSide(color: opt['borderColor'], width: 1),
                    labelStyle: TextStyle(
                      color: opt['textColor']
                    ),
                    selected: false,
                    onSelected: (_) => Navigator.pop(context, opt),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecordingState() async {
    if (_isRecording) {
      final path = await recorderService.stopRecording();
      if (path != null) {
        setState(() {
          _recordingPath = path;
        });
      }
    } else {
      await recorderService.startRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  void dispose() {
    recorderService.dispose();
    super.dispose();
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

  Future<void> _pickMood(BuildContext context) async {
    Map<String, dynamic>? result = await showStringPicker(context);
    if (result != null) {
      setState(() => _selectedMood = result);
    }
  }

  void _clearMood() {
    setState(() {
      _selectedMood = null;
    });
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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("When did this happen? Enter a date, pls...")),
      );
      return;
    }
    if (_recordingPath == '' && _journalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Girlll, what do I save? There's not text or audio...")),
      );
      return;
    }

    String? audioName;
    if (_recordingPath != '') {
      audioName = await recorderService.saveFile();

      if (audioName == null || audioName == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not save audio...")),
        );
        return;
      }
    }

    Entry newEntry = Entry(
        content: _journalController.text,
        date: DateFormat.yMMMd().format(_selectedDate!),
        images: _pickedImages,
        audio: audioName,
        mood: _selectedMood?['label']);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: AddEntryTitle(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DatePicker(
                    fn: () => _pickDate(context), selectedDate: _selectedDate),
                MoodPicker(fn: () => _pickMood(context), mood: _selectedMood, clearMood: _clearMood),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _showRecorder
                  ? AudioInput(
                      isRecording: _isRecording,
                      toggleRecordingState: _toggleRecordingState,
                      recordingPath: _recordingPath,
                      removeAudio: () async {
                        await recorderService.deleteFile();
                        setState(() {
                          _recordingPath = '';
                        });
                      })
                  : JournalInput(journalController: _journalController),
            ),
            SizedBox(
              height: 5,
            ),
            AudioButton(
                showRecorder: _showRecorder,
                fn: () async {
                  setState(() {
                    _showRecorder = !_showRecorder;
                  });
                }),
            ImagesInput(
                handleImagesSelection: _handleImagesSelection,
                pickedImages: _pickedImages,
                directory: _directory,
                removePickedImage: _removePickedImage),
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
