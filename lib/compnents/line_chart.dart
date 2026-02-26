import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class DailyRecord {
  final DateTime date;
  final int count;
  const DailyRecord(this.date, this.count);
}

class LineChart extends StatefulWidget {
  /// Pixel height of the chart canvas (excludes the year selector).
  final double chartHeight;

  const LineChart({
    super.key,
    this.chartHeight = 300,
  });

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late List<int> _years;
  int _selectedYear = DateTime.now().year;
  late List<DailyRecord> _cumulativeData;
  bool isLoading = true;

  // ── Tooltip state ─────────────────────────────────────────────────────
  // Index into cumulativeData of the currently highlighted point, or null.
  int? _tooltipIndex;

  @override
  void initState() {
    super.initState();
    _setYears();
    _setup(null);
  }

  List<int> createListRange(int a, int b) {
    // Determine the length (number of items) in the range, inclusive of a and b.
    int length = (b - a).abs() + 1;
    int start = (a < b) ? a : b;

    return List<int>.generate(length, (i) => start + i);
  }

  Future<void> _setYears() async {
    final res = await EntryProvider().getEarliestYear();
    if (res != null) {
      setState(() {
        _years = createListRange(res, DateTime.now().year);
      });
    }
  }

  Future<void> _setup(int? year) async {
    print('------$year');
    final res =
        await EntryProvider().getYearlyCumulativeCounts(year ?? _selectedYear);
    final convertedData = convertToDailyData(res);
    setState(() {
      _cumulativeData = convertedData;
      if (year == null) isLoading = false;
    });
  }

  List<DailyRecord> convertToDailyData(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();

    return sortedKeys.map((key) {
      return DailyRecord(DateTime.parse(key), data[key] as int);
    }).toList();
  }

  /// Converts a tap's local X position into the nearest data-point index.
  ///
  /// [tapX]  – x coordinate of the tap in the widget's local space.
  /// [width] – total width of the chart widget.
  /// [total] – number of data points (days in the year).
  ///
  /// Returns null if the tap is outside the drawable chart area.
  int? _indexFromTap(double tapX, double width, int total) {
    const pL = _ChartPainter.pL;
    const pR = _ChartPainter.pR;
    final cw = width - pL - pR;

    if (tapX < pL || tapX > pL + cw) return null;

    // Map tap to a day-of-year index (0…daysInYear-1)
    final fraction = (tapX - pL) / cw;
    final daysInYear = DateTime(_selectedYear + 1, 1, 1)
        .difference(DateTime(_selectedYear, 1, 1))
        .inDays;
    final dayIndex =
        (fraction * (daysInYear - 1)).round().clamp(0, daysInYear - 1);

    // Clamp to the range of available data so we never go out of bounds.
    // Also return null if the tap is beyond the last available data point.
    if (dayIndex >= _cumulativeData.length) return null;

    return dayIndex;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Happy monents in the year!!",
                style: TextStyle(
                    color: Colors.pink.shade900,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 32,
              ),
              // ── Year selector ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Choose Year: ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.pink.shade200,
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: DropdownButton<int>(
                        underline: Container(),
                        iconEnabledColor: Colors.pink.shade900,
                        iconDisabledColor:
                            Colors.pink.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                        dropdownColor: Colors.pink.shade100,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink.shade900,
                            fontWeight: FontWeight.bold),
                        value: _selectedYear,
                        items: _years
                            .map((y) => DropdownMenuItem<int>(
                                value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (y) {
                          if (y == null) return;
                          setState(() {
                            _selectedYear = y;
                            _tooltipIndex = null;
                          });
                          _setup(y);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Chart + gesture layer ────────────────────────────────────────
              SizedBox(
                height: widget.chartHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      // Tap down: snap tooltip to the nearest data point.
                      onTapDown: (details) {
                        final idx = _indexFromTap(
                          details.localPosition.dx,
                          constraints.maxWidth,
                          _cumulativeData.length,
                        );
                        setState(() => _tooltipIndex = idx);
                      },

                      // Horizontal drag: slide tooltip along the line.
                      onHorizontalDragUpdate: (details) {
                        final idx = _indexFromTap(
                          details.localPosition.dx,
                          constraints.maxWidth,
                          _cumulativeData.length,
                        );
                        setState(() => _tooltipIndex = idx);
                      },
                      child: _LineChart(
                        data: _cumulativeData,
                        year: _selectedYear,
                        tooltipIndex: _tooltipIndex,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}

// ═════════════════════════════════════════════
// INTERNAL CHART WIDGET
// ═════════════════════════════════════════════

class _LineChart extends StatelessWidget {
  final List<DailyRecord> data;
  final int year;
  final int? tooltipIndex;

  const _LineChart({
    required this.data,
    required this.year,
    required this.tooltipIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ChartPainter(
        data: data,
        year: year,
        tooltipIndex: tooltipIndex,
      ),
    );
  }
}

// ═════════════════════════════════════════════
// CUSTOM PAINTER
// ═════════════════════════════════════════════

class _ChartPainter extends CustomPainter {
  final List<DailyRecord> data;
  final int year;
  final int? tooltipIndex;

  // Exposed as static so _CumulativeChartWidgetState can reference them
  // when converting a tap X position into a data index.
  static const double pL = 64, pR = 0, pT = 16, pB = 48;

  _ChartPainter({
    required this.data,
    required this.year,
    required this.tooltipIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // ── Derived dimensions ─────────────────────────────────────────────
    final cw = size.width - pL - pR;
    final ch = size.height - pT - pB;
    final maxVal = data.last.count.toDouble();
    // final total = data.length.toDouble();
    final daysInYear =
        DateTime(year + 1, 1, 1).difference(DateTime(year, 1, 1)).inDays;
    final total = daysInYear.toDouble();
    // ── Coordinate helpers ─────────────────────────────────────────────
    // Maps a day index (0…total-1) to canvas X.
    double xOf(int i) => pL + (i / (total - 1)) * cw;
    // Maps a cumulative value to canvas Y (inverted: 0 is top).
    // double yOf(num v) => pT + ch - (v / maxVal) * ch;
    const topPad = 0.1; // 10% breathing room above the max value
    double yOf(num v) => pT + ch - (v / maxVal) * ch * (1 - topPad);

    // ── Shared styles ──────────────────────────────────────────────────
    final labelStyle = TextStyle(color: Colors.pink.shade900, fontSize: 11);
    final gridPaint = Paint()
      ..color = Colors.pink.shade200
      ..strokeWidth = 1;

    // ── Y-axis grid lines & labels ─────────────────────────────────────
    for (int i = 0; i <= 5; i++) {
      final v = (maxVal * i / 5).round();
      final y = yOf(v);
      canvas.drawLine(Offset(pL, y), Offset(pL + cw, y), gridPaint);
      // Right-align within [0, pL-8] so labels sit flush left of the axis.
      _text(canvas, '$v'.padLeft(4, ' '), Offset(35, y - 7), labelStyle,
          width: pL - 8, align: TextAlign.right);
    }

    // ── X-axis month ticks & labels ────────────────────────────────────
    for (int m = 1; m <= 12; m++) {
      final idx = DateTime(year, m, 1).difference(DateTime(year, 1, 1)).inDays;
      if (idx >= daysInYear) continue;
      final x = xOf(idx);
      canvas.drawLine(Offset(x, pT + ch), Offset(x, pT + ch + 4), gridPaint);
      _text(canvas, _mon(m), Offset(x - 8, pT + ch + 8), labelStyle, width: 24);
    }

    // ── Y-axis title ───────────────────────────────────────────────────────
    // The title is rotated 90° counter-clockwise, so we save/restore the
    // canvas transform to avoid affecting anything else.
    const yTitle = 'Cumulative Entry Count'; // ← change to your label

    final titlePainter = TextPainter(
      text: TextSpan(
        text: yTitle,
        style: TextStyle(
          color: Colors.pink.shade900,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();

    // Rotate around the point where we want the text centred.
    // Centre vertically on the chart, and place it against the left edge.
    final titleX = titlePainter.height; // distance from left edge
    final titleY = pT + ch / 2; // vertical midpoint of chart

    canvas.translate(titleX, titleY);
    canvas.rotate(-pi / 2); // 90° counter-clockwise

    // After rotation, "right" is "up" — paint centred on origin.
    titlePainter.paint(
      canvas,
      Offset(-titlePainter.width / 2, -titlePainter.height / 2),
    );

    canvas.restore();

    // ── Gradient fill under the line ───────────────────────────────────
    final fillPath = Path()..moveTo(xOf(0), yOf(data[0].count));
    for (int i = 1; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i].count));
    }
    fillPath
      ..lineTo(xOf(data.length - 1), pT + ch)
      ..lineTo(xOf(0), pT + ch)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.pink.shade900.withOpacity(0.35),
            Colors.pink.shade900.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(pL, pT, cw, ch)),
    );

    // ── Line ───────────────────────────────────────────────────────────
    final linePath = Path()..moveTo(xOf(0), yOf(data[0].count));
    for (int i = 1; i < data.length; i++) {
      linePath.lineTo(xOf(i), yOf(data[i].count));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = Colors.pink.shade500
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Axes ───────────────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = Colors.pink.shade900
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(pL, pT), Offset(pL, pT + ch), axisPaint);
    canvas.drawLine(Offset(pL, pT + ch), Offset(pL + cw, pT + ch), axisPaint);

    // ── Tooltip ────────────────────────────────────────────────────────
    // Only rendered while the user is touching the chart.
    if (tooltipIndex != null) {
      final idx = tooltipIndex!;
      final entry = data[idx];
      final px = xOf(idx);
      final py = yOf(entry.count);

      // Vertical crosshair from top of chart to X axis.
      canvas.drawLine(
        Offset(px, pT),
        Offset(px, pT + ch),
        Paint()
          ..color = Colors.pink.shade300.withOpacity(0.5)
          ..strokeWidth = 1,
      );

      // Highlight dot — outer filled circle.
      canvas.drawCircle(
          Offset(px, py), 5, Paint()..color = Colors.pink.shade700);
      // Inner white dot to create a ring effect.
      canvas.drawCircle(Offset(px, py), 3, Paint()..color = Colors.white);

      // ── Bubble ──────────────────────────────────────────────────────
      // Label: "15 Mar" on the first line, cumulative value on the second.
      final date = entry.date;
      final dateStr = '${date.day} ${_mon(date.month)}';
      final valueStr = entry.count.toString();
      final tooltipText = '$dateStr\n$valueStr';

      // Lay out the text first so we know how large to make the bubble.
      final tp = TextPainter(
        text: TextSpan(
          text: tooltipText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      const pad = 8.0; // inner padding inside the bubble
      const arrowH = 6.0; // height of the downward-pointing arrow

      final bubbleW = tp.width + pad * 2;
      final bubbleH = tp.height + pad * 2;

      // Centre the bubble on px; clamp so it never overflows left/right edges.
      double bx = px - bubbleW / 2;
      bx = bx.clamp(pL, pL + cw - bubbleW);

      // Position the bubble above the highlight dot with a small gap.
      final by = py - bubbleH - arrowH - 6;

      // Rounded rectangle background.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bubbleW, bubbleH),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.pink.shade800,
      );

      // Downward-pointing triangle arrow connecting bubble to dot.
      canvas.drawPath(
        Path()
          ..moveTo(px - 6, by + bubbleH) // left base of arrow
          ..lineTo(px + 6, by + bubbleH) // right base of arrow
          ..lineTo(px, by + bubbleH + arrowH) // tip pointing at the dot
          ..close(),
        Paint()..color = Colors.pink.shade800,
      );

      // Render the text centred inside the bubble.
      tp.paint(canvas, Offset(bx + pad, by + pad));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _text(Canvas canvas, String s, Offset o, TextStyle style,
      {double width = 40, TextAlign align = TextAlign.left}) {
    (TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width))
        .paint(canvas, o);
  }

  String _mon(int m) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];

  // Repaint whenever data, year, or the active tooltip index changes.
  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data != data || old.year != year || old.tooltipIndex != tooltipIndex;
}
