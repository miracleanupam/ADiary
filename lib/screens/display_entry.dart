import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:flutter/material.dart';

class DisplayEntry extends StatefulWidget {
  const DisplayEntry({super.key});

  @override
  State<DisplayEntry> createState() => _DisplayEntryState();
}

class _DisplayEntryState extends State<DisplayEntry> {
  Entry? _entry;
  final EntryProvider entryProvider = EntryProvider();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getRandomEntry();
  }

  void _getRandomEntry() async {
    Entry? randomEntry = await entryProvider.getRandomEntry(_entry?.id);
    setState(() {
      _entry = randomEntry;
    });
  }

  Widget getJournalBody() {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              '${_entry?.content}',
                              style: TextStyle(fontSize: 24),
                            ))))),
            Divider(),
            SizedBox(height: 16),
            AlevatedButton(
                onPressed: _getRandomEntry,
                icon: Icons.cached,
                text: 'See Another'),
          ],
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
              child: Text(
                'You will find moments of happiness! It will pass. <3',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade900),
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
