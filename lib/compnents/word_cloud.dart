import 'dart:math';

import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';

// ─── WordCloud widget ─────────────────────────────────────────────────────────

class WordCloud extends StatefulWidget {
  final double height;

  const WordCloud({super.key, this.height = 600});

  @override
  State<WordCloud> createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  Map<String, int> _frequencies = {};
  bool _isLoading = true;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final freq = await EntryProvider().fetchMoodFrequencies();
    if (mounted) {
      setState(() {
        _frequencies = freq;
        _isLoading = false;
      });
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_frequencies.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'No mood data yet',
            style: TextStyle(color: PinkColors.shade300),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Cloud',
          style: TextStyle(
            color: PinkColors.shade900,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
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

// ─── Word placement model ─────────────────────────────────────────────────────

class _PlacedWord {
  final String word;
  final int count;
  final Offset center;
  final double fontSize;
  final Color pillColor;
  final Color textColor;
  final Rect bounds;

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

// ─── CustomPainter ────────────────────────────────────────────────────────────

class _WordCloudPainter extends CustomPainter {
  final Map<String, int> frequencies;

  static const _pillColors = [
    Color(0xFFFFE8D6), Color(0xFFFFD6E0), Color(0xFFFFC2D4),
    Color(0xFFFFADC4), Color(0xFFE8C4F0), Color(0xFFD4B8F0),
    Color(0xFFB8D4F8), Color(0xFFB8ECD4), Color(0xFFA8DFB0),
    Color(0xFFFFF0A0), Color(0xFFFFD080), Color(0xFFFFB07A),
    Color(0xFFFF8FAB), Color(0xFFE8456A), Color(0xFFB5173D),
  ];

  static const _textColors = [
    Color(0xFF7A3B1E), Color(0xFF8B1A35), Color(0xFF8B1A35),
    Color(0xFF6B0F28), Color(0xFF4A1A6B), Color(0xFF2D0F6B),
    Color(0xFF0F2B6B), Color(0xFF0F4B2B), Color(0xFF1A3B1E),
    Color(0xFF5C4A00), Color(0xFF5C3000), Color(0xFF6B2500),
    Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF),
  ];

  static const double _pillPadH = 12.0;
  static const double _pillPadV = 6.0;
  static const double _minFont = 12.0;
  static const double _maxFont = 25.0;
  static const double _angleStep = 0.28;
  static const double _radiusStep = 1.5;
  static const double _boundsPadding = 8.0;

  const _WordCloudPainter({required this.frequencies});

  @override
  bool shouldRepaint(_WordCloudPainter old) => old.frequencies != frequencies;

  @override
  void paint(Canvas canvas, Size size) {
    if (frequencies.isEmpty) return;
    for (final word in _layoutWords(size)) {
      _drawPill(canvas, word);
    }
  }

  // ─── Layout ───────────────────────────────────────────────────────────────

  List<_PlacedWord> _layoutWords(Size size) {
    final maxFreq = frequencies.values.reduce(max).toDouble();
    final minFreq = frequencies.values.reduce(min).toDouble();
    final freqRange = (maxFreq - minFreq).clamp(1.0, double.infinity);
    final random = Random(42);
    final placed = <_PlacedWord>[];

    for (final entry in frequencies.entries) {
      final t = (entry.value - minFreq) / freqRange;
      final fontSize = _minFont + t * (_maxFont - _minFont);
      final colorIndex = (t * (_pillColors.length - 1)).round();
      final bounds = _measureBounds(entry.key, fontSize);
      final position = _spiralPlace(size, bounds, placed, random);

      if (position == null) continue;

      placed.add(_PlacedWord(
        word: entry.key,
        count: entry.value,
        center: position,
        fontSize: fontSize,
        pillColor: _pillColors[colorIndex],
        textColor: _textColors[colorIndex],
        bounds: Rect.fromCenter(
          center: position,
          width: bounds.width,
          height: bounds.height,
        ),
      ));
    }

    return placed;
  }

  Size _measureBounds(String word, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: word,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'IndieFlower',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return Size(
      tp.width + _pillPadH * 2 + 12 + _boundsPadding,
      tp.height + _pillPadV * 2 + 10 + _boundsPadding,
    );
  }

  Offset? _spiralPlace(
    Size canvas,
    Size bounds,
    List<_PlacedWord> placed,
    Random random,
  ) {
    double angle = random.nextDouble() * 2 * pi;
    double radius = 0;

    while (radius < canvas.width) {
      final cx = canvas.width / 2 + radius * cos(angle);
      final cy = canvas.height / 2 + radius * sin(angle);
      final candidate = Rect.fromCenter(
        center: Offset(cx, cy),
        width: bounds.width,
        height: bounds.height,
      );

      final inBounds = candidate.left >= 0 &&
          candidate.right <= canvas.width &&
          candidate.top >= 0 &&
          candidate.bottom <= canvas.height;

      if (inBounds && !placed.any((p) => p.bounds.overlaps(candidate))) {
        return Offset(cx, cy);
      }

      angle += _angleStep;
      radius += _radiusStep;
    }

    return null;
  }

  // ─── Drawing ──────────────────────────────────────────────────────────────

  void _drawPill(Canvas canvas, _PlacedWord w) {
    final wordTp = _buildTextPainter(
      w.word,
      TextStyle(
        fontSize: w.fontSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'IndieFlower',
        color: w.textColor,
      ),
    );

    final badgeLabel = w.count > 99 ? '99+' : '${w.count}';
    final badgeFontSize = (w.fontSize * 0.55).clamp(9.0, 14.0);
    final badgeTp = _buildTextPainter(
      badgeLabel,
      TextStyle(
        fontSize: badgeFontSize,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );

    final badgeR = (badgeTp.width / 2 + 4).clamp(10.0, 18.0);
    final pillW = wordTp.width + _pillPadH * 2;
    final pillH = wordTp.height + _pillPadV * 2;
    final pillRadius = pillH / 2;
    final pillLeft = w.center.dx - pillW / 2;
    final pillTop = w.center.dy - pillH / 2;
    final pillRect = Rect.fromLTWH(pillLeft, pillTop, pillW, pillH);
    final pillRRect = RRect.fromRectAndRadius(pillRect, Radius.circular(pillRadius));

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        pillRect.translate(0, 2),
        Radius.circular(pillRadius),
      ),
      Paint()
        ..color = w.pillColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Pill background
    canvas.drawRRect(pillRRect, Paint()..color = w.pillColor);

    // Word text
    wordTp.paint(canvas, Offset(pillLeft + _pillPadH, pillTop + _pillPadV));

    // Badge
    final badgeCx = pillLeft + pillW - badgeR * 0.6;
    final badgeCy = pillTop + badgeR * 0.6;
    canvas.drawCircle(
      Offset(badgeCx, badgeCy),
      badgeR,
      Paint()..color = PinkColors.shade900,
    );
    badgeTp.paint(
      canvas,
      Offset(badgeCx - badgeTp.width / 2, badgeCy - badgeTp.height / 2),
    );
  }

  TextPainter _buildTextPainter(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}