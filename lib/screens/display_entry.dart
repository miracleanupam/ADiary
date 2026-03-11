import 'dart:io';

import 'package:adiary/compnents/audio_player.dart';
import 'package:adiary/compnents/mood_picker.dart';
import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/compnents/alevated_button.dart';
import 'package:adiary/compnents/styled_text.dart';
import 'package:adiary/models/entry_notifier.dart';
import 'package:adiary/screens/full_screen_gallery.dart';
import 'package:adiary/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adiary/constants.dart' as constants;

// ─── DisplayEntry ─────────────────────────────────────────────────────────────

class DisplayEntry extends StatefulWidget {
  final int? selectedEntryId;

  const DisplayEntry({super.key, this.selectedEntryId});

  @override
  State<DisplayEntry> createState() => _DisplayEntryState();
}

class _DisplayEntryState extends State<DisplayEntry> {
  Entry? _entry;
  Map<String, dynamic>? _mood;
  String? _audioPath;
  String? _directory;

  final _scrollController = ScrollController();

  static const _blossomShadow = Shadow(
    color: Colors.pink,
    blurRadius: 10,
    offset: Offset.zero,
  );

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadImageDirectory();
    _loadEntry();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadImageDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) setState(() => _directory = dir.path);
  }

  Future<void> _loadEntry() async {
    if (widget.selectedEntryId == null) {
      return _loadRandomEntry();
    }

    final entry = await EntryProvider().getEntryById(widget.selectedEntryId!);
    if (entry == null) {
      return _loadRandomEntry();
    }

    final mood = _findMood(entry.mood);
    final audioPath = await _resolveAudioPath(entry.audio);

    if (mounted) {
      setState(() {
        _entry = entry;
        _mood = mood;
        _audioPath = audioPath;
      });
    }
  }

  Future<void> _loadRandomEntry() async {
    final entry = await EntryProvider().getRandomEntry(_entry?.id);
    final mood = _findMood(entry?.mood);
    final audioPath = await _resolveAudioPath(entry?.audio);

    if (mounted) {
      setState(() {
        _entry = entry;
        _mood = mood;
        _audioPath = audioPath;
      });
    }
  }

  Future<String?> _resolveAudioPath(String? audioName) async {
    if (audioName == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$audioName');
    return await file.exists() ? file.path : null;
  }

  Map<String, dynamic>? _findMood(String? label) {
    if (label == null) return null;
    try {
      return constants.MOOD_OPTIONS.firstWhere((m) => m['label'] == label);
    } catch (_) {
      return null;
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────────

  void _promptDelete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure? It can not be undone'),
        actions: [
          TextButton(
            onPressed: _confirmDelete,
            child: const Text('Yes', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("No, I'll keep it!", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final auth = ADauthenticationService();
    final authenticated = await auth.authenticate(context);

    if (!authenticated) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final succeeded = await EntryProvider().delete(_entry?.id);
    if (succeeded && mounted) {
      EntryNotifierScope.of(context).refresh();
      _loadRandomEntry();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete, sorry!...')),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _entry == null ? _buildEmptyState() : _buildEntryView();
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: PinkColors.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text("Oops! Didn't find happy memories :(  "),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'You will find moments of happiness! It will pass. <3',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: PinkColors.shade900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AlevatedButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.home,
              text: 'Go Back',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryView() {
    return Scaffold(
      backgroundColor: PinkColors.shade100,
      appBar: AppBar(
        flexibleSpace: constants.appBarBg,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _buildAppBarTitle(),
      ),
      body: Container(
        decoration: constants.bgDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEntryHeader(),
              const Divider(),
              Expanded(child: _buildScrollableContent()),
              if (_audioPath != null) AudioPlayerWidget(filePath: _audioPath!),
              const Divider(),
              const SizedBox(height: 16),
              AlevatedButton(
                onPressed: _loadRandomEntry,
                icon: Icons.cached,
                text: 'See Another',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    final blossomStyle = TextStyle(shadows: [_blossomShadow]);
    return Text.rich(TextSpan(children: [
      TextSpan(text: '🌸🌸', style: blossomStyle),
      const TextSpan(text: ' Remember this? '),
      TextSpan(text: '🌸🌸', style: blossomStyle),
    ]));
  }

  Widget _buildEntryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(
              fontSize: 24,
              fontFamily: 'IndieFlower',
              fontWeight: FontWeight.bold,
            ),
          ),
          label: Text.rich(TextSpan(children: [
            TextSpan(text: '${_entry?.date} '),
            TextSpan(
              text: '🪷🪷',
              style: TextStyle(shadows: [_blossomShadow]),
            ),
          ])),
        ),
        IconButton.filled(
          onPressed: _promptDelete,
          icon: const Icon(Icons.delete_outline_outlined),
          style: IconButton.styleFrom(
              backgroundColor: PinkColors.shade100,
              foregroundColor: PinkColors.shade300,
              side: const BorderSide(color: PinkColors.shade300, width: 1)),
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 1,
      thumbColor: Theme.of(context).colorScheme.primary,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(4),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const StyledText(value: 'Memory'),
                if (_mood != null && _mood!.isNotEmpty)
                  Transform.scale(scale: 0.6, child: MoodPill(fn: () {}, mood: _mood)),
                const SizedBox(height: 16),
                Text('${_entry?.content}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 24),
                if (_entry?.images != null && _entry!.images!.isNotEmpty)
                  _buildImageSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 24),
        const StyledText(value: 'Images'),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entry!.images!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenGallery(
                  imagePaths: _entry!.images!,
                  initialIndex: index,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(6),
              child: Image.file(
                File('$_directory/${_entry!.images![index]}'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

