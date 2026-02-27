import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';

final List SUMMARY_CARDS = [
  {
    'title': 'Total Entries',
    'icon': Icons.numbers,
    'query': 'COUNT',
  },
  {
    'title': 'With Audio',
    'icon': Icons.audio_file_outlined,
    'query': 'COUNT_WITH_AUDIO'
  },
  {
    'title': 'With Images',
    'icon': Icons.image_outlined,
    'query': 'COUNT_WITH_IMAGES'
  },
  {
    'title': 'Total Images',
    'icon': Icons.image_rounded,
    'query': 'IMAGE_COUNT'
  },
  {
    'title': 'Current Streak',
    'icon': Icons.calendar_today,
    'query': 'CURRENT_STREAK'
  },
  {
    'title': 'Longest Streak',
    'icon': Icons.calendar_month,
    'query': 'LONGEST_STREAK'
  },
  {
    'title': 'Frequent Mood',
    'icon': Icons.emoji_emotions_outlined,
    'query': 'FREQUENT_MOOD'
  },
  {
    'title': '# of Days',
    'icon': Icons.onetwothree,
    'query': 'DAYS_WITH_ENTRIES'
  },

  // {
  //   'title': '',
  //   'icon': ,
  //   'query': ''
  // }
];

class Summary extends StatelessWidget {
  const Summary({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      children: List.generate(SUMMARY_CARDS.length, (idx) {
        return StatCard(idx: idx);
      }),
    );
  }
}

class StatCard extends StatefulWidget {
  final int idx;
  const StatCard({super.key, required this.idx});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  Map<String, dynamic>? cardData;
  bool isLoading = true;
  String value = '-';

  @override
  void initState() {
    super.initState();
    cardData = SUMMARY_CARDS[widget.idx];
    _getStat();
  }

  void _getStat() async {
    dynamic result = 0;
    switch (cardData!['query']) {
      case 'COUNT':
        result = await EntryProvider().getCount();
        break;
      case 'COUNT_WITH_AUDIO':
        result = await EntryProvider().getCountWithAudio();
        break;
      case 'COUNT_WITH_IMAGES':
        result = await EntryProvider().getCountWithImages();
        break;
      case 'DISCARDED_COUNT':
        result = await EntryProvider().getDiscardedCount();
        break;
      case 'IMAGE_COUNT':
        result = await EntryProvider().getImageCount();
      case 'FREQUENT_MOOD':
        result = await EntryProvider().getFrequentMood();
      case 'LONGEST_STREAK':
        result = await EntryProvider().getLongestStreak();
      case 'CURRENT_STREAK':
        result = await EntryProvider().getCurrentStreak();
      case 'DAYS_WITH_ENTRIES':
        result = await EntryProvider().getDaysWithEntries();
      default:
        break;
    }
    setState(() {
      value = '$result';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  border: Border.all(color: Colors.pink.shade900),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    cardData!['icon'],
                    size: 60,
                    color: Colors.pink.shade900,
                  ),
                  VerticalDivider(),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cardData!['title'],
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade900),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade400),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
