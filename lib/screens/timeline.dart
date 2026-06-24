import 'package:adiary/compnents/date_separator.dart';
import 'package:adiary/compnents/timeline_card.dart';
import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final ScrollController scrollController = ScrollController();
  List<Object> entries = [];

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadTimelineEntries(currentPage);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
              (scrollController.position.maxScrollExtent - 10) &&
          !loadingMore &&
          hasMore) {
        await _loadTimelineEntries(currentPage);
      }
    });
  }

  // Group entries by date
  Map<String, List<Entry>> _groupEntriesByDate(List<Entry> entries) {
    final Map<String, List<Entry>> grouped = {};
    for (final entry in entries) {
      final dateKey = entry.date;
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    return grouped;
  }

  Future<void> _loadTimelineEntries(int? page) async {
    if (loadingMore) return;

    loadingMore = true;
    List<Entry> newEntries = await EntryProvider().timelinePage(page ?? 1);
    hasMore = newEntries.length == 10;
    currentPage = currentPage + (newEntries.isEmpty ? 0 : 1);
    final grouped = _groupEntriesByDate(newEntries);
    final List<dynamic> items = [];

    for (final dateKey in grouped.keys) {
      items.addAll(grouped[dateKey]!); // entries for that date
      items.add(dateKey); // date separator
    }

    setState(() {
      entries = [...entries, ...items];
      loading = false;
    });
    loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: entries.isEmpty
                        ? Text(
                          "There is no data yet!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: PinkColors.shade900),
                        )
                        : ListView.builder(
                            reverse: true,
                            itemCount: entries.length,
                            controller: scrollController,
                            itemBuilder: (context, index) {
                              // Loading indicator at the bottom
                              if (index == entries.length - 1 && hasMore) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final item = entries[index];

                              // Date separator
                              if (item is String) {
                                return DateSeparator(date: item);
                              }

                              // Entry tile
                              return TimelineCard(entry: item as Entry);
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
  }
}
