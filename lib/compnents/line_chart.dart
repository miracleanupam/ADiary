import 'dart:math';

import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class DailyRecord {
  final DateTime date;
  final int count;

  const DailyRecord(this.date, this.count);
}

// ─── LineChart widget ─────────────────────────────────────────────────────────

class LineChart extends StatefulWidget {
  final double chartHeight;

  const LineChart({super.key, this.chartHeight = 300});

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late List<int> _years;
  int _selectedYear = DateTime.now().year;
  late List<DailyRecord> _cumulativeData;
  bool _isLoading = true;
  int? _tooltipIndex;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadYears();
    _loadData(null);
  }

  // ─── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadYears() async {
    final earliest = await EntryProvider().getEarliestYear();
    if (earliest != null && mounted) {
      setState(() => _years = _rangeInclusive(earliest, DateTime.now().year));
    }
  }

  Future<void> _loadData(int? year) async {
    final res =
        await EntryProvider().getYearlyCumulativeCounts(year ?? _selectedYear);
    if (mounted) {
      setState(() {
        _cumulativeData = _convertToDailyData(res);
        if (year == null) _isLoading = false;
      });
    }
  }

  List<int> _rangeInclusive(int a, int b) {
    final start = a < b ? a : b;
    return List<int>.generate((b - a).abs() + 1, (i) => start + i);
  }

  List<DailyRecord> _convertToDailyData(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();
    return sortedKeys
        .map((key) => DailyRecord(DateTime.parse(key), data[key] as int))
        .toList();
  }

  // ─── Interaction ───────────────────────────────────────────────────────────

  int? _indexFromTap(double tapX, double width) {
    const pL = _ChartPainter.pL;
    const pR = _ChartPainter.pR;
    final cw = width - pL - pR;
    if (tapX < pL || tapX > pL + cw) return null;

    final daysInYear = DateTime(_selectedYear + 1, 1, 1)
        .difference(DateTime(_selectedYear, 1, 1))
        .inDays;
    final dayIndex =
        ((tapX - pL) / cw * (daysInYear - 1)).round().clamp(0, daysInYear - 1);

    return dayIndex >= _cumulativeData.length ? null : dayIndex;
  }

  void _onYearChanged(int year) {
    setState(() {
      _selectedYear = year;
      _tooltipIndex = null;
    });
    _loadData(year);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Happy moments in the year!!',
          style: TextStyle(
            color: PinkColors.shade900,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        _buildYearSelector(),
        const SizedBox(height: 8),
        _buildChartArea(),
      ],
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Choose Year: ',
          style: TextStyle(
            fontSize: 16,
            color: PinkColors.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: PinkColors.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox.shrink(),
            iconEnabledColor: PinkColors.shade900,
            iconDisabledColor: PinkColors.shade900.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            dropdownColor: PinkColors.shade100,
            style: TextStyle(
              fontSize: 16,
              color: PinkColors.shade900,
              fontWeight: FontWeight.bold,
            ),
            items: _years
                .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
                .toList(),
            onChanged: (y) {
              if (y != null) _onYearChanged(y);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    return SizedBox(
      height: widget.chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          void updateTooltip(double dx) {
            final idx = _indexFromTap(dx, constraints.maxWidth);
            setState(() => _tooltipIndex = idx);
          }

          return GestureDetector(
            onTapDown: (d) => updateTooltip(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => updateTooltip(d.localPosition.dx),
            child: _LineChartCanvas(
              data: _cumulativeData,
              year: _selectedYear,
              tooltipIndex: _tooltipIndex,
            ),
          );
        },
      ),
    );
  }
}

// ─── Internal canvas widget ───────────────────────────────────────────────────

class _LineChartCanvas extends StatelessWidget {
  final List<DailyRecord> data;
  final int year;
  final int? tooltipIndex;

  const _LineChartCanvas({
    required this.data,
    required this.year,
    required this.tooltipIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter:
          _ChartPainter(data: data, year: year, tooltipIndex: tooltipIndex),
    );
  }
}

// ─── CustomPainter ────────────────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  final List<DailyRecord> data;
  final int year;
  final int? tooltipIndex;

  static const double pL = 64, pR = 0, pT = 16, pB = 48;
  static const double _topPad = 0.1;
  static const double _tooltipPad = 8.0;
  static const double _arrowHeight = 6.0;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  const _ChartPainter({
    required this.data,
    required this.year,
    required this.tooltipIndex,
  });

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data != data || old.year != year || old.tooltipIndex != tooltipIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final cw = size.width - pL - pR;
    final ch = size.height - pT - pB;
    final maxVal = data.last.count.toDouble();
    final daysInYear = DateTime(year + 1, 1, 1)
        .difference(DateTime(year, 1, 1))
        .inDays
        .toDouble();

    double xOf(int i) => pL + (i / (daysInYear - 1)) * cw;
    double yOf(num v) => pT + ch - (v / maxVal) * ch * (1 - _topPad);

    final labelStyle = TextStyle(color: PinkColors.shade900, fontSize: 11);
    final gridPaint = Paint()
      ..color = PinkColors.shade200
      ..strokeWidth = 1;

    _drawGrid(canvas, size, cw, ch, maxVal, yOf, gridPaint, labelStyle);
    _drawXAxis(canvas, ch, cw, xOf, daysInYear.toInt(), gridPaint, labelStyle);
    _drawYAxisTitle(canvas, ch);
    _drawFill(canvas, cw, ch, xOf, yOf);
    _drawLine(canvas, xOf, yOf);
    _drawAxes(canvas, cw, ch);
    if (tooltipIndex != null) {
      _drawTooltip(canvas, cw, ch, xOf, yOf, tooltipIndex!);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double cw, double ch, double maxVal,
      double Function(num) yOf, Paint gridPaint, TextStyle labelStyle) {
    for (int i = 0; i <= 5; i++) {
      final v = (maxVal * i / 5).round();
      final y = yOf(v);
      canvas.drawLine(Offset(pL, y), Offset(pL + cw, y), gridPaint);
      _paintText(canvas, '$v'.padLeft(4, ' '), Offset(35, y - 7), labelStyle,
          width: pL - 8, align: TextAlign.right);
    }
  }

  void _drawXAxis(Canvas canvas, double ch, double cw, double Function(int) xOf,
      int daysInYear, Paint gridPaint, TextStyle labelStyle) {
    for (int m = 1; m <= 12; m++) {
      final idx = DateTime(year, m, 1).difference(DateTime(year, 1, 1)).inDays;
      if (idx >= daysInYear) continue;
      final x = xOf(idx);
      canvas.drawLine(Offset(x, pT + ch), Offset(x, pT + ch + 4), gridPaint);
      _paintText(canvas, _months[m - 1], Offset(x - 8, pT + ch + 8), labelStyle,
          width: 24);
    }
  }

  void _drawYAxisTitle(Canvas canvas, double ch) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Cumulative Entry Count',
        style: TextStyle(
          color: PinkColors.shade900,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(tp.height, pT + ch / 2);
    canvas.rotate(-pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _drawFill(Canvas canvas, double cw, double ch, double Function(int) xOf,
      double Function(num) yOf) {
    final path = Path()..moveTo(xOf(0), yOf(data[0].count));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(xOf(i), yOf(data[i].count));
    }
    path
      ..lineTo(xOf(data.length - 1), pT + ch)
      ..lineTo(xOf(0), pT + ch)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PinkColors.shade900.withValues(alpha: 0.35),
            PinkColors.shade900.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(pL, pT, cw, ch)),
    );
  }

  void _drawLine(
      Canvas canvas, double Function(int) xOf, double Function(num) yOf) {
    final path = Path()..moveTo(xOf(0), yOf(data[0].count));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(xOf(i), yOf(data[i].count));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = PinkColors.shade500
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawAxes(Canvas canvas, double cw, double ch) {
    final paint = Paint()
      ..color = PinkColors.shade900
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(pL, pT), Offset(pL, pT + ch), paint);
    canvas.drawLine(Offset(pL, pT + ch), Offset(pL + cw, pT + ch), paint);
  }

  void _drawTooltip(Canvas canvas, double cw, double ch,
      double Function(int) xOf, double Function(num) yOf, int idx) {
    final entry = data[idx];
    final px = xOf(idx);
    final py = yOf(entry.count);

    // Crosshair
    canvas.drawLine(
      Offset(px, pT),
      Offset(px, pT + ch),
      Paint()
        ..color = PinkColors.shade300.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );

    // Dot
    canvas.drawCircle(Offset(px, py), 5, Paint()..color = PinkColors.shade700);
    canvas.drawCircle(Offset(px, py), 3, Paint()..color = Colors.white);

    // Bubble
    final dateStr = '${entry.date.day} ${_months[entry.date.month - 1]}';
    final tp = TextPainter(
      text: TextSpan(
        text: '$dateStr\n${entry.count}',
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

    final bubbleW = tp.width + _tooltipPad * 2;
    final bubbleH = tp.height + _tooltipPad * 2;
    final bx = (px - bubbleW / 2).clamp(pL, pL + cw - bubbleW);
    final by = py - bubbleH - _arrowHeight - 6;
    final bgPaint = Paint()..color = PinkColors.shade800;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bubbleW, bubbleH),
        const Radius.circular(6),
      ),
      bgPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(px - 6, by + bubbleH)
        ..lineTo(px + 6, by + bubbleH)
        ..lineTo(px, by + bubbleH + _arrowHeight)
        ..close(),
      bgPaint,
    );
    tp.paint(canvas, Offset(bx + _tooltipPad, by + _tooltipPad));
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style,
      {double width = 40, TextAlign align = TextAlign.left}) {
    (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width))
        .paint(canvas, offset);
  }
}
