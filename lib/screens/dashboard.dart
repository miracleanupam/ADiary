import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/add_entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/display_entry.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _entryCount = 0;

  @override
  void initState() {
    super.initState();
    _countEntries();
  }

  void _countEntries() async {
    int count = await EntryProvider().getCount();
    setState(() {
      _entryCount = count;
    });
  }

  Widget showCount() {
    return Column(
      children: [
        Text(
          '🌸',
          style: TextStyle(
              shadows: [
                Shadow(
                    color: Colors.pink.shade900,
                    blurRadius: 10,
                    offset: Offset(0, 0))
              ],
              fontSize: 32,
              color: Colors.pink.shade900,
              fontFamily: 'IndieFlower',
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 32,
        ),
        Text.rich(
          TextSpan(
            text: 'You have collected',
            children: [
              TextSpan(
                  text: ' $_entryCount',
                  style: TextStyle(color: Colors.pink.shade600)),
              TextSpan(text: ' good memories so far...'),
            ],
            style: TextStyle(
                fontSize: 32,
                color: Colors.pink.shade900,
                fontFamily: 'IndieFlower',
                fontWeight: FontWeight.bold),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 32,
        ),
        Text(
          '🌸🌸🌸',
          style: TextStyle(
              shadows: [
                Shadow(
                    color: Colors.pink.shade900,
                    blurRadius: 10,
                    offset: Offset(0, 0))
              ],
              fontSize: 32,
              color: Colors.pink.shade900,
              fontFamily: 'IndieFlower',
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget addEntryButton() {
    return AlevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEntry(fn: _countEntries)),
          );
        },
        icon: Icons.add,
        text: 'Add More');
  }

  Widget memoryButton() {
    return AlevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DisplayEntry()),
          );
        },
        icon: Icons.sentiment_very_satisfied,
        text: 'Go down the memory lane');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showCount(),
          SizedBox(
            height: 64,
          ),
          addEntryButton(),
          memoryButton(),
        ],
      ),
    );
  }
}
