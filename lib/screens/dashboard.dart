import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/add_entry.dart';
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
        Text('🌷🌷🌷'),
        SizedBox(
          height: 32,
        ),
        Text.rich(
          TextSpan(
            text: 'You have collected',
            children: [
              TextSpan(
                  text: ' $_entryCount',
                  style: TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.bold)),
              TextSpan(text: ' good memories so far...'),
            ],
            style: TextStyle(
              fontSize: 32,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 32,
        ),
        Text('🌸🌸🌸'),
      ],
    );
  }

  Widget addEntryButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEntry()),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.favorite_border),
          Text('Add More'),
        ],
      ),
    );
  }

  Widget memoryButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DisplayEntry()),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.sentiment_very_satisfied),
          Text('Go down the memory lane.'),
        ],
      ),
    );
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
