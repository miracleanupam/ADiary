import 'dart:io';

import 'package:adiary/compnents/audio_player.dart';
import 'package:adiary/compnents/mood_picker.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:adiary/constants.dart' as constants;

class DisplayEntry extends StatefulWidget {
  const DisplayEntry({super.key});

  @override
  State<DisplayEntry> createState() => _DisplayEntryState();
}

class _DisplayEntryState extends State<DisplayEntry> {
  Entry? _entry;
  final EntryProvider entryProvider = EntryProvider();
  final ScrollController scrollController = ScrollController();
  String? _directory;
  Map<String, dynamic>? _mood;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _getRandomEntry();
    _getImageDirectory();
  }

  void _getRandomEntry() async {
    Entry? randomEntry = await entryProvider.getRandomEntry(_entry?.id);
    Map<String, dynamic>? entryMood = findMood(randomEntry?.mood);
    final directory = await getApplicationDocumentsDirectory();
    final audioPath = '${directory.path}/${randomEntry?.audio}';
    File audioFile = File(audioPath);
    bool audioFileExists = await audioFile.exists();

    setState(() {
      _entry = randomEntry;
      _mood = entryMood;
      _audioPath = audioFileExists ? audioFile.path : null;
    });
  }

  void _getImageDirectory() async {
    Directory imageDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      _directory = imageDirectory.path;
    });
  }

  Map<String, dynamic>? findMood(String? mood) {
    if (mood == null) return null;

    try {
      return constants.MOOD_OPTIONS.firstWhere((item) => item['label'] == mood);
    } catch (_) {
      return null;
    }
  }

  Widget getJournalBody() {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        flexibleSpace: constants.appBarBg,
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
          TextSpan(text: ' Remember this? '),
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
      body: Container(
        decoration: constants.bgDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(
                        fontSize: 24,
                        fontFamily: 'IndieFlower',
                        fontWeight: FontWeight.bold)),
                label: Text.rich(TextSpan(children: [
                  TextSpan(text: '${_entry?.date} '),
                  TextSpan(
                      text: '🪷🪷',
                      style: TextStyle(shadows: [
                        Shadow(
                            color: Colors.pink.shade900,
                            blurRadius: 10,
                            offset: Offset(0, 0))
                      ]))
                ]))),
            Divider(),
            Expanded(
                child: RawScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    thickness: 1,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(4),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 24,
                                  ),
                                  StyledText(value: "Memory"),
                                  (_mood == null || _mood!.isEmpty)
                                      ? const SizedBox.shrink()
                                      : MoodPill(fn: () {}, mood: _mood),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    '${_entry?.content}',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  if (_entry?.images != null &&
                                      _entry!.images.isNotEmpty) ...[
                                    Divider(),
                                    SizedBox(
                                      height: 24,
                                    ),
                                    StyledText(value: "Images"),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _entry!.images.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FullScreenGallery(
                                                    imagePaths: _entry!.images,
                                                    initialIndex:
                                                        index, // start from tapped image
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadiusGeometry
                                                        .circular(6),
                                                child: Image.file(File(
                                                    "$_directory/${_entry!.images[index]}"))));
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          height: 20,
                                        );
                                      },
                                    )
                                  ],
                                ],
                              ))),
                    ))),
            if (_audioPath != null) AudioPlayerWidget(filePath: _audioPath!),
            Divider(),
            SizedBox(
              height: 16,
            ),
            AlevatedButton(
                onPressed: _getRandomEntry,
                icon: Icons.cached,
                text: 'See Another'),
            SizedBox(
              height: 16,
            )
          ]),
        ),
      ),
    );
  }

  Widget getNoJurnalBody() {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Oops! Didn't find happy memories."),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'You will find moments of happiness! It will pass. <3',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade900),
                ),
              ),
            ),
            SizedBox(height: 16),
            AlevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icons.home,
                text: 'Go Back'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _entry == null ? getNoJurnalBody() : getJournalBody();
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  String? _directory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _getImageDirectory();
  }

  void _getImageDirectory() async {
    Directory imageDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      _directory = imageDirectory.path;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (_isLoading) ...[Center(child: CircularProgressIndicator())],
          if (!_isLoading) ...[
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.imagePaths.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(
                      File("$_directory/${widget.imagePaths[index]}")),
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: widget.imagePaths[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                );
              },
              onPageChanged: (index) => setState(() => _currentIndex = index),
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            // Optional image index indicator
            Positioned(
              bottom: 30,
              child: Text(
                "${_currentIndex + 1} / ${widget.imagePaths.length}",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
