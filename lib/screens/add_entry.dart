import 'package:adiary/compnents/audio_button.dart';
import 'package:adiary/compnents/audio_input.dart';
import 'package:adiary/compnents/add_entry_title.dart';
import 'package:adiary/compnents/date_picker.dart';
import 'package:adiary/compnents/images_input.dart';
import 'package:adiary/compnents/journal_input.dart';
import 'package:adiary/compnents/mood_picker.dart';
import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/compnents/alevated_button.dart';
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
  // — Entry state —
  int? _entryId;
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedMood;
  List<String> _pickedImages = [];
  String? _directory;

  // — UI state —
  bool _showRecorder = false;

  // — Recording state —
  bool _isRecording = false;
  String _recordingPath = '';

  // — Services —
  final _journalController = TextEditingController();
  final _imageService = ImageService();
  final _recorderService = RecorderService();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadImageDirectory();
  }

  @override
  void dispose() {
    _journalController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  // ─── Setup ────────────────────────────────────────────────────────────────

  Future<void> _loadImageDirectory() async {
    final dir = await getTemporaryDirectory();
    if (mounted) setState(() => _directory = dir.path);
  }

  // ─── Date ─────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── Mood ─────────────────────────────────────────────────────────────────

  Future<void> _pickMood() async {
    final result = await _showMoodPicker();
    if (result != null) setState(() => _selectedMood = result);
  }

  void _clearMood() => setState(() => _selectedMood = null);

  Future<Map<String, dynamic>?> _showMoodPicker() {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PinkColors.shade100,
        title: const Text('Vibe it! Pretty Lady!'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: constants.MOOD_OPTIONS
              .map((opt) => GestureDetector(
                    onTap: () => Navigator.pop(context, opt),
                    child: MoodPill(fn: () => Navigator.pop(context, opt), mood: opt),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ─── Recording ────────────────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorderService.stopRecording();
      if (path != null) setState(() => _recordingPath = path);
    } else {
      await _recorderService.startRecording();
    }
    setState(() => _isRecording = !_isRecording);
  }

  Future<void> _removeAudio() async {
    await _recorderService.deleteFile();
    setState(() => _recordingPath = '');
  }

  // ─── Images ───────────────────────────────────────────────────────────────

  Future<void> _addImages() async {
    final picked = await _imageService.pickImages();
    setState(() => _pickedImages = [..._pickedImages, ...picked]);
  }

  Future<void> _removeImage(int index) async {
    await _imageService.removeImage(_pickedImages[index]);
    setState(() => _pickedImages.removeAt(index));
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _saveEntry() async {
    if (!_validate()) return;

    final audioName = await _recorderService.saveFile();
    await _imageService.saveFiles();

    final entry = Entry(
      content: _journalController.text,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      images: _pickedImages.isEmpty ? null : _pickedImages,
      audio: audioName,
      mood: _selectedMood?['label'],
    );

    if (_entryId != null) entry.id = _entryId;

    final saved = await EntryProvider().upsert(entry);
    setState(() => _entryId = saved.id);

    await widget.fn();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory Preserved!')),
      );
    }
  }

  bool _validate() {
    if (_journalController.text.isEmpty && _recordingPath.isEmpty) {
      _showSnackBar("Girlll, what do I save? There's no text or audio...");
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PinkColors.shade100,
      appBar: AppBar(
        flexibleSpace: constants.appBarBg,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const AddEntryTitle(),
      ),
      body: Container(
        decoration: constants.bgDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const SizedBox(height: 16),
              Expanded(child: _buildContentInput()),
              const SizedBox(height: 5),
              AudioButton(
                showRecorder: _showRecorder,
                fn: () => setState(() => _showRecorder = !_showRecorder),
              ),
              const SizedBox(height: 16),
              ImagesInput(
                handleImagesSelection: _addImages,
                pickedImages: _pickedImages,
                directory: _directory,
                removePickedImage: _removeImage,
              ),
              const SizedBox(height: 16),
              const Divider(),
              AlevatedButton(
                onPressed: _saveEntry,
                icon: Icons.favorite_border,
                text: 'Save Memory',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(fn: _pickDate, selectedDate: _selectedDate),
        MoodPicker(fn: _pickMood, mood: _selectedMood, clearMood: _clearMood),
      ],
    );
  }

  Widget _buildContentInput() {
    if (_showRecorder) {
      return AudioInput(
        isRecording: _isRecording,
        toggleRecordingState: _toggleRecording,
        recordingPath: _recordingPath,
        removeAudio: _removeAudio,
      );
    }
    return JournalInput(journalController: _journalController);
  }
}