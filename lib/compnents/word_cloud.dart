import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WordCloud extends StatefulWidget {
  final double height;

  const WordCloud({super.key, this.height = 600});

  @override
  State<WordCloud> createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  Map<String, int> _frequencies = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final freq = await EntryProvider().fetchMoodFrequencies();
    setState(() {
      _frequencies = freq;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // return SizedBox(
      //   height: widget.height,
      //   child: const Center(child: CircularProgressIndicator()),
      // );
      return Center(child: CircularProgressIndicator());
    }

    if (_frequencies.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'No mood data yet',
            style: TextStyle(color: Colors.pink.shade300),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mood Cloud",
          style: TextStyle(
              color: Colors.pink.shade900,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 32,
        ),
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) => CustomPaint(
              size: Size(constraints.maxWidth, widget.height),
              painter: _WordCloudPainter(frequencies: _frequencies),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// WORD PLACEMENT MODEL
// ═════════════════════════════════════════════

class _PlacedWord {
  final String word;
  final int count;
  final Offset center;
  final double fontSize;
  final Color pillColor; // fill color of the pill
  final Color textColor; // word text color
  final Rect bounds; // full bounding box used for overlap detection

  const _PlacedWord({
    required this.word,
    required this.count,
    required this.center,
    required this.fontSize,
    required this.pillColor,
    required this.textColor,
    required this.bounds,
  });
}

// ═════════════════════════════════════════════
// CUSTOM PAINTER
// ═════════════════════════════════════════════

class _WordCloudPainter extends CustomPainter {
  final Map<String, int> frequencies;

  static const _pillColors = [
    Color(0xFFFFE8D6), // peach — lowest frequency
    Color(0xFFFFD6E0), // blush pink
    Color(0xFFFFC2D4), // soft pink
    Color(0xFFFFADC4), // pink
    Color(0xFFE8C4F0), // lavender
    Color(0xFFD4B8F0), // soft purple
    Color(0xFFB8D4F8), // periwinkle blue
    Color(0xFFB8ECD4), // mint green
    Color(0xFFA8DFB0), // sage green
    Color(0xFFFFF0A0), // soft yellow
    Color(0xFFFFD080), // golden yellow
    Color(0xFFFFB07A), // peach orange
    Color(0xFFFF8FAB), // hot pink
    Color(0xFFE8456A), // deep pink
    Color(0xFFB5173D), // darkest — highest frequency
  ];

  static const _textColors = [
    Color(0xFF7A3B1E), // on peach
    Color(0xFF8B1A35), // on blush
    Color(0xFF8B1A35), // on soft pink
    Color(0xFF6B0F28), // on pink
    Color(0xFF4A1A6B), // on lavender
    Color(0xFF2D0F6B), // on soft purple
    Color(0xFF0F2B6B), // on periwinkle
    Color(0xFF0F4B2B), // on mint
    Color(0xFF1A3B1E), // on sage
    Color(0xFF5C4A00), // on yellow
    Color(0xFF5C3000), // on golden
    Color(0xFF6B2500), // on peach orange
    Color(0xFFFFFFFF), // on hot pink
    Color(0xFFFFFFFF), // on deep pink
    Color(0xFFFFFFFF), // on darkest
  ];

  _WordCloudPainter({required this.frequencies});

  @override
  void paint(Canvas canvas, Size size) {
    if (frequencies.isEmpty) return;

    final placed = _layoutWords(size);

    for (final w in placed) {
      _drawPill(canvas, w);
    }
  }

  /// Draws a pill chip containing the word and a small count badge.
  ///
  /// Layout inside the pill:
  ///   [ word text ]  then a small circular badge top-right with the count.
  void _drawPill(Canvas canvas, _PlacedWord w) {
    // ── Measure word text ──────────────────────────────────────────────
    final wordTp = TextPainter(
      text: TextSpan(
        text: w.word,
        style: TextStyle(
          fontSize: w.fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'IndieFlower',
          color: w.textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // ── Badge metrics ──────────────────────────────────────────────────
    // Badge is a small circle sitting on the top-right corner of the pill.
    final badgeFontSize = (w.fontSize * 0.55).clamp(9.0, 14.0);
    final badgeLabel = w.count > 99 ? '99+' : '${w.count}';

    final badgeTp = TextPainter(
      text: TextSpan(
        text: badgeLabel,
        style: TextStyle(
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Badge circle radius — large enough to contain the text.
    final badgeR = (badgeTp.width / 2 + 4).clamp(10.0, 18.0);

    // ── Pill geometry ──────────────────────────────────────────────────
    const pillPadH = 12.0; // horizontal inner padding
    const pillPadV = 6.0; // vertical inner padding

    final pillW = wordTp.width + pillPadH * 2;
    final pillH = wordTp.height + pillPadV * 2;
    final pillRadius = pillH / 2; // fully rounded ends

    // Top-left of the pill, offset so the pill is centred on w.center.
    final pillLeft = w.center.dx - pillW / 2;
    final pillTop = w.center.dy - pillH / 2;
    final pillRect = Rect.fromLTWH(pillLeft, pillTop, pillW, pillH);
    final pillRRect =
        RRect.fromRectAndRadius(pillRect, Radius.circular(pillRadius));

    // ── Draw pill shadow ───────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = w.pillColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        pillRect.translate(0, 2),
        Radius.circular(pillRadius),
      ),
      shadowPaint,
    );

    // ── Draw pill background ───────────────────────────────────────────
    canvas.drawRRect(pillRRect, Paint()..color = w.pillColor);

    // ── Draw word text centred in pill ─────────────────────────────────
    wordTp.paint(
      canvas,
      Offset(pillLeft + pillPadH, pillTop + pillPadV),
    );

    // ── Draw badge circle ──────────────────────────────────────────────
    // Badge sits on the top-right corner of the pill, half-overlapping.
    final badgeCx = pillLeft + pillW - badgeR * 0.6;
    final badgeCy = pillTop + badgeR * 0.6;

    // Badge background — slightly darker than the pill.
    canvas.drawCircle(
      Offset(badgeCx, badgeCy),
      badgeR,
      Paint()..color = Colors.pink.shade900,
    );

    // Badge count text, centred in the circle.
    badgeTp.paint(
      canvas,
      Offset(badgeCx - badgeTp.width / 2, badgeCy - badgeTp.height / 2),
    );
  }

  /// Spiral layout — same algorithm as before but bounds now account for
  /// the badge circle that protrudes outside the pill.
  List<_PlacedWord> _layoutWords(Size size) {
    final maxFreq = frequencies.values.reduce(max).toDouble();
    final minFreq = frequencies.values.reduce(min).toDouble();
    final freqRange = (maxFreq - minFreq).clamp(1.0, double.infinity);

    const minFont = 12.0;
    const maxFont = 25.0;

    final random = Random(42);
    final placed = <_PlacedWord>[];

    for (final entry in frequencies.entries) {
      final word = entry.key;
      final count = entry.value;
      final freq = count.toDouble();

      final t = (freq - minFreq) / freqRange;
      final fontSize = minFont + t * (maxFont - minFont);

      final colorIndex = (t * (_pillColors.length - 1)).round();
      final pillColor = _pillColors[colorIndex];
      final textColor = _textColors[colorIndex];

      // Measure the pill size for this word to use in overlap detection.
      final tp = TextPainter(
        text: TextSpan(
          text: word,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              fontFamily: 'IndieFlower'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const pillPadH = 12.0;
      const pillPadV = 6.0;
      // Add extra margin for the badge that pokes out of the top-right.
      final boundsW = tp.width + pillPadH * 2 + 12;
      final boundsH = tp.height + pillPadV * 2 + 10;

      // Spiral search.
      Offset? position;
      double angle = random.nextDouble() * 2 * pi;
      double radius = 0;
      const angleStep = 0.28;
      const radiusStep = 1.5;

      while (radius < size.width) {
        final cx = size.width / 2 + radius * cos(angle);
        final cy = size.height / 2 + radius * sin(angle);

        final candidate = Rect.fromCenter(
          center: Offset(cx, cy),
          width: boundsW + 8,
          height: boundsH + 8,
        );

        if (candidate.left < 0 ||
            candidate.right > size.width ||
            candidate.top < 0 ||
            candidate.bottom > size.height) {
          angle += angleStep;
          radius += radiusStep;
          continue;
        }

        if (!placed.any((p) => p.bounds.overlaps(candidate))) {
          position = Offset(cx, cy);
          break;
        }

        angle += angleStep;
        radius += radiusStep;
      }

      if (position == null) continue;

      placed.add(_PlacedWord(
        word: word,
        count: count,
        center: position,
        fontSize: fontSize,
        pillColor: pillColor,
        textColor: textColor,
        bounds: Rect.fromCenter(
          center: position,
          width: boundsW + 8,
          height: boundsH + 8,
        ),
      ));
    }

    return placed;
  }

  @override
  bool shouldRepaint(_WordCloudPainter old) => old.frequencies != frequencies;
}
