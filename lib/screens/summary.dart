import 'package:adiary/models/entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Constants / theme helpers
// ─────────────────────────────────────────────

const _kCardRadius = 16.0;
const _kSectionGap = 16.0;

TextStyle _labelStyle(BuildContext context) => TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.pink.shade900,
    );

TextStyle _bigNumberStyle(BuildContext context) => TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w900,
      color: Colors.pink.shade500,
    );

TextStyle _unitStyle(BuildContext context) => TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.pink.shade700,
      fontFamily: 'IndieFlower',
    );

TextStyle _captionStyle(BuildContext context) => TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.pink.shade400,
    );

// ─────────────────────────────────────────────
// Root widget
// ─────────────────────────────────────────────

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  int totalEntries = 0;
  int happyDays = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  int imageCount = 0;
  int audioCount = 0;
  String frequentMood = '-';
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
      provider.getCount(),              // 0
      provider.getCurrentStreak(),      // 1
      provider.getLongestStreak(),      // 2
      provider.getImageCount(),         // 3
      provider.getCountWithAudio(),     // 4
      provider.getFrequentMood(),       // 5  format: "<mood>-<count>"
      provider.getDaysWithEntries(),    // 6
      provider.getDayWithMostEntries(), // 7  format: "<day>=<count>"
      provider.getDiscardedCount(),     // 8
    ]);

    setState(() {
      totalEntries       = results[0] as int;
      currentStreak      = results[1] as int;
      longestStreak      = results[2] as int;
      imageCount         = results[3] as int;
      audioCount         = results[4] as int;
      frequentMood       = '${results[5]}';
      happyDays          = results[6] as int;
      dayWithMostEntries = results[7] as String;
      deletedEntries     = results[8] as int;
      isLoading          = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.pink.shade900),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero: total memories
            _HeaderCard(totalEntries: totalEntries, happyDays: happyDays),

            const SizedBox(height: _kSectionGap),

            // Streak pair
            _StreakRow(currentStreak: currentStreak, longestStreak: longestStreak),

            const SizedBox(height: _kSectionGap),

            // Media breakdown
            _MediaSummaryCard(imageCount: imageCount, audioCount: audioCount),

            const SizedBox(height: _kSectionGap),

            // Most-entries day + deleted count
            _DayAndDeletedRow(
              dayWithMostEntries: dayWithMostEntries,
              deletedEntries: deletedEntries,
            ),

            const SizedBox(height: _kSectionGap),

            // Frequent mood
            _FrequentMoodCard(
              frequentMood: frequentMood,
            ),

            const SizedBox(height: _kSectionGap),

            // Affirmation footer
            _AffirmationCard(happyDays: happyDays),

            const SizedBox(height: _kSectionGap),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section widgets
// ─────────────────────────────────────────────

/// Hero card: total entry count and happy-day tally.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.totalEntries, required this.happyDays});

  final int totalEntries;
  final int happyDays;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.favorite_outline, label: 'Total Memories'),

          const SizedBox(height: 8),

          // Large entry count — scales down if locale produces long numbers
          _ScaledRichText(
            minHeight: 56,
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
                  fontFamily: 'IndieFlower',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Happy-days line with sparkle icons (no emoji text)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.sparkles, color: Colors.pink, size: 16),
              const SizedBox(width: 8),
              Text(
                'That\'s $totalEntries doses for the soul ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade400,
                  fontFamily: 'IndieFlower',
                ),
              ),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.sparkles, color: Colors.pink.shade500, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// Side-by-side current / longest streak cards.
class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.currentStreak, required this.longestStreak});

  final int currentStreak;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return _TwoColumnRow(
      left: _StatBlock(
        icon: Icons.local_fire_department_outlined,
        iconColor: Colors.deepOrange,
        title: 'Current Streak',
        value: currentStreak,
        unit: currentStreak != 1 ? 'days' : 'day',
        captionIcon: Icons.favorite_rounded,
        captionIconColor: Colors.pink.shade500,
        caption: 'Keep going',
        valueMinHeight: 56,
      ),
      right: _StatBlock(
        icon: Icons.emoji_events_outlined,
        iconColor: Colors.deepOrange,
        title: 'Longest Streak',
        value: longestStreak,
        unit: longestStreak != 1 ? 'days' : 'day',
        captionIcon: Icons.sign_language,
        captionIconColor: Colors.pink.shade500,
        caption: 'Great Job',
        valueMinHeight: 56,
      ),
    );
  }
}

/// Media breakdown: images, audio, total.
class _MediaSummaryCard extends StatelessWidget {
  const _MediaSummaryCard({required this.imageCount, required this.audioCount});

  final int imageCount;
  final int audioCount;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.photo_camera_outlined, label: 'Media Summary'),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MediaRow(icon: Icons.photo_library,      label: 'Images',      value: imageCount),
                const SizedBox(height: 8),
                _MediaRow(icon: Icons.music_note, label: 'Audio',       value: audioCount),
                const SizedBox(height: 8),
                _MediaRow(icon: Icons.bar_chart_outlined,  label: 'Total Media', value: imageCount + audioCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Side-by-side: day with most entries and deleted-entry count.
class _DayAndDeletedRow extends StatelessWidget {
  const _DayAndDeletedRow({
    required this.dayWithMostEntries,
    required this.deletedEntries,
  });

  final String dayWithMostEntries;
  final int deletedEntries;

  @override
  Widget build(BuildContext context) {
    // Provider format: "<day>=<count>"
    final parts = dayWithMostEntries.split('=');
    final day   = parts.first;
    final count = parts.last;

    return _TwoColumnRow(
      left: _StatBlock(
        icon: Icons.show_chart_outlined,
        iconColor: Colors.deepOrange,
        title: 'Most Entries On',
        valueText: day,
        caption: '$count entries',
        valueMinHeight: 56,
      ),
      right: _StatBlock(
        icon: Icons.delete_outline,
        iconColor: Colors.deepOrange,
        title: 'Deleted Memories',
        value: deletedEntries,
        unit: 'entries',
        caption: deletedEntries > 0 ? "That's unfortunate!!" : 'Nice!!',
        valueMinHeight: 56,
      ),
    );
  }
}

/// Card showing the most frequently logged mood.
class _FrequentMoodCard extends StatelessWidget {
  const _FrequentMoodCard({
    required this.frequentMood,
  });

  final String frequentMood;

  @override
  Widget build(BuildContext context) {
    final mood = frequentMood.split('-').first;
    final count = frequentMood.split('-').last;

    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.emoji_emotions_outlined, label: 'Frequent Mood'),

          const SizedBox(height: 8),

          _ScaledRichText(
            minHeight: 56,
            children: [
              TextSpan(text: mood, style: _bigNumberStyle(context)),
            ],
          ),

          const SizedBox(height: 8),

          Text('$count times', style: _captionStyle(context)),
        ],
      ),
    );
  }
}

/// Motivational footer card.
class _AffirmationCard extends StatelessWidget {
  const _AffirmationCard({required this.happyDays});

  final int happyDays;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      tint: const Color(0xFFFFF0F5),
      child: Row(
        children: [
          Icon(Icons.local_florist_rounded, color: Colors.pink.shade300, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: _ScaledRichText(
              textAlign: TextAlign.center,
              children: [
                TextSpan(
                  text: "You've recorded happiness on ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink.shade700,
                    height: 1.5,
                  ),
                ),
                TextSpan(
                  text: '$happyDays',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.pink.shade500,
                  ),
                ),
                TextSpan(
                  text: " days.\nThat's beautiful.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.local_florist_rounded, color: Colors.pink.shade300, size: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable building blocks
// ─────────────────────────────────────────────

/// Standard card title: icon + text label, label scales to fit.
class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label, style: _labelStyle(context)),
          ),
        ),
      ],
    );
  }
}

/// Stat block used inside side-by-side cards.
/// Pass [value] + [unit] for a numeric display, or [valueText] for free-form text.
/// Set [valueMinHeight] to the same value on both blocks in a [_TwoColumnRow]
/// so both cards reserve the same height for their value line.
class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.unit,
    this.valueText,
    required this.caption,
    this.captionIcon,
    this.captionIconColor,
    this.valueMinHeight,
  }) : assert(
          value != null || valueText != null,
          'Provide either value or valueText',
        );

  final IconData icon;
  final Color iconColor;
  final String title;
  final int? value;
  final String? unit;
  final String? valueText; // used when the display isn't a plain number
  final String caption;

  /// Optional icon shown inline after the caption text.
  final IconData? captionIcon;

  /// Color for [captionIcon]. Defaults to pink.shade400.
  final Color? captionIconColor;

  /// Reserve this height for the value line so paired cards stay the same
  /// height. Pass the same value to both blocks in a [_TwoColumnRow].
  final double? valueMinHeight;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with scaling label
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: _labelStyle(context)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Value + optional unit — FittedBox prevents wrapping
          _ScaledRichText(
            minHeight: valueMinHeight,
            children: [
              TextSpan(
                text: valueText ?? '$value',
                style: _bigNumberStyle(context),
              ),
              if (unit != null)
                TextSpan(text: ' $unit', style: _unitStyle(context)),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(caption, style: _captionStyle(context)),
              if (captionIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  captionIcon,
                  size: 16,
                  color: captionIconColor ?? Colors.pink.shade400,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A single media metric row: icon, label, and value.
class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.pink.shade300, size: 24),
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

/// Two equal-width, equal-height children in a horizontal row.
/// [IntrinsicHeight] lets Flutter measure the natural height of both children
/// first, then [CrossAxisAlignment.stretch] grows the shorter one to match —
/// without inflating beyond what the content actually needs.
class _TwoColumnRow extends StatelessWidget {
  const _TwoColumnRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }
}

/// [RichText] wrapped in [FittedBox] so content scales down instead of wrapping.
/// [minHeight] should match the largest fontSize used in [children] so that
/// when text scales down the widget does not shrink in height, keeping paired
/// cards the same height without any layout tricks.
class _ScaledRichText extends StatelessWidget {
  const _ScaledRichText({
    required this.children,
    this.textAlign = TextAlign.start,
    this.minHeight,
  });

  final List<InlineSpan> children;
  final TextAlign textAlign;

  /// Reserve vertical space equal to the tallest font size used in [children].
  /// Pass the largest fontSize so the widget never shrinks below that height
  /// even when FittedBox scales the text down.
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(children: children),
      ),
    );

    if (minHeight == null) return content;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight!),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────
// StatCard (formerly _GlassCard)
// ─────────────────────────────────────────────

/// Frosted-glass style container used for every summary card.
/// Exported (no underscore) so it can be reused elsewhere in the app.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.child, this.tint});

  final Widget child;

  /// Optional background tint; defaults to white.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(0.45),
        borderRadius: BorderRadius.circular(_kCardRadius),
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