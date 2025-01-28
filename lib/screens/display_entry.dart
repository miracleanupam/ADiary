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
  final TextEditingController _journalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getRandomEntry();
  }

  void _getRandomEntry() async {
    Entry? randomEntry = await entryProvider.getRandomEntry(_entry?.id);
    _journalController.value =
        TextEditingValue(text: randomEntry == null ? '' : randomEntry.content);
    setState(() {
      _entry = randomEntry;
    });
  }

  Widget getJournalBody() {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("🌸💝 Remember this?"),
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
                label: Text('${_entry?.date}')),
            Expanded(
              child: TextField(
                controller: _journalController,
                textAlignVertical: TextAlignVertical.top,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "A full heart...",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
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
                style: TextStyle(fontSize: 18),
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
