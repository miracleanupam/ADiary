import 'package:adiary/models/entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  // Stat values
  int totalEntries = 0;
  int happyDays = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  int imageCount = 0;
  int audioCount = 0;
  int countWithImages = 0;
  int countWithAudio = 0;
  String frequentMood = '-';
  String moodFrequency = '-';
  String dayWithMostEntries = '-';
  int deletedEntries = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final provider = EntryProvider();
    final results = await Future.wait([
      provider.getCount(),
      provider.getCurrentStreak(),
      provider.getLongestStreak(),
      provider.getImageCount(),
      provider.getCountWithAudio(),
      provider.getCountWithImages(),
      provider.getFrequentMood(),
      provider.getDaysWithEntries(),
      provider.getDayWithMostEntries(),
      provider.getDiscardedCount(),
    ]);

    setState(() {
      totalEntries = results[0] as int;
      currentStreak = results[1] as int;
      longestStreak = results[2] as int;
      imageCount = results[3] as int;
      audioCount = results[4] as int;
      countWithImages = results[5] as int;
      frequentMood = '${results[6]}'.split('-').first;
      moodFrequency = '${results[6]}'.split('-').last;
      happyDays = results[7] as int;
      dayWithMostEntries = results[8] as String;
      deletedEntries = results[9] as int;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.pink.shade900,
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  Header(totalEntries: totalEntries, happyDays: happyDays),

                  const SizedBox(height: 16),

                  // ── Streak row ──
                  Streak(
                      currentStreak: currentStreak,
                      longestStreak: longestStreak),

                  const SizedBox(height: 16),

                  // ── Media Summary card ──
                  _GlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('📷',
                                      style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Media Summary',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _MediaRow(
                                  emoji: '🖼️',
                                  label: 'Images',
                                  value: imageCount),
                              const SizedBox(height: 4),
                              _MediaRow(
                                  emoji: '🎵',
                                  label: 'Audio',
                                  value: audioCount),
                              const SizedBox(height: 4),
                              _MediaRow(
                                emoji: '📊',
                                label: 'Total Media',
                                value: imageCount + audioCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // ── Mood and Max Entries ──
                  DayAndDeleted(
                      frequentMood: frequentMood,
                      dayWithMostEntries: dayWithMostEntries,
                      deletedEntries: deletedEntries),
                  const SizedBox(
                    height: 16,
                  ),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 6),
                            Text(
                              'Frequent Mood',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: frequentMood,
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.pink.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$moodFrequency times',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.pink.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // ── Footer affirmation ──
                  _GlassCard(
                    tint: const Color(0xFFFFF0F5),
                    child: Row(
                      children: [
                        const Text('🌼', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.pink.shade700,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                    text: "You've recorded happiness on "),
                                TextSpan(
                                  text: '$happyDays',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: Colors.pink.shade500,
                                  ),
                                ),
                                const TextSpan(
                                    text: " days.\nThat's beautiful."),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('🌸', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          );
  }
}

class DayAndDeleted extends StatelessWidget {
  const DayAndDeleted({
    super.key,
    required this.frequentMood,
    required this.dayWithMostEntries,
    required this.deletedEntries,
  });

  final String frequentMood;
  final String dayWithMostEntries;
  final int deletedEntries;

  @override
  Widget build(BuildContext context) {
    final day = dayWithMostEntries.split('=').first;
    final count = dayWithMostEntries.split('=').last;
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 6),
                    Text(
                      'Most Entries On',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: day,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count entries',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 6),
                    Text(
                      'Deleted Memories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.pink.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$deletedEntries',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade500,
                        ),
                      ),
                      TextSpan(
                        text: ' entries',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink.shade700,
                            fontFamily: 'IndieFlower'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deletedEntries > 0 ? "That's unfortunate!!" : 'Nice!!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Streak extends StatelessWidget {
  const Streak({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 6),
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$currentStreak',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade500,
                        ),
                      ),
                      TextSpan(
                        text: ' day${currentStreak != 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink.shade700,
                            fontFamily: 'IndieFlower'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep going 💕',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 6),
                    Text(
                      'Longest Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.pink.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$longestStreak',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.pink.shade500,
                        ),
                      ),
                      TextSpan(
                        text: ' day${longestStreak != 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink.shade700,
                            fontFamily: 'IndieFlower'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Great Job 💕',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.totalEntries,
    required this.happyDays,
  });

  final int totalEntries;
  final int happyDays;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩷', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Total Memories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.pink.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$totalEntries',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.pink.shade500,
                  ),
                ),
                TextSpan(
                  text: '  entries',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade800,
                      fontFamily: 'IndieFlower'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
              text: TextSpan(
            children: [
              WidgetSpan(
                  child: Icon(
                CupertinoIcons.sparkles,
                color: Colors.orange,
              )),
              TextSpan(
                  text: ' $happyDays',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.pink.shade600,
                  )),
              TextSpan(
                text: ' happy days ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink.shade800,
                    fontFamily: 'IndieFlower'),
              ),
              WidgetSpan(
                  child: Icon(
                CupertinoIcons.sparkles,
                color: Colors.orange,
              ))
            ],
          )),
        ],
      ),
    );
  }
}

// ── Reusable frosted glass card ──
class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? tint;

  const _GlassCard({required this.child, this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.pink.shade500.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade200.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Media row item ──
class _MediaRow extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;

  const _MediaRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.pink.shade800,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.pink.shade500,
          ),
        ),
      ],
    );
  }
}
