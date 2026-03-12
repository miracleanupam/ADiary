import 'dart:math';

import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class BarData {
  final String label;
  final double value;

  const BarData({required this.label, required this.value});
}

// ─── BarChart widget ──────────────────────────────────────────────────────────

class BarChart extends StatefulWidget {
  const BarChart({super.key});

  static const double yAxisWidth = 32.0;
  static const double xAxisHeight = 64.0;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  bool _isLoading = true;
  double _maxValue = 0;
  late List<BarData> _monthlyData;
  late final ScrollController _scrollController;
  int? _selectedIndex;

  static const double _barWidth = 10;
  static const double _barSpacing = 16;
  static const int _yDivisions = 5;
  static const double _chartHeight = 300;
  static const double _scrollToMonthsFromEnd = 1;

  static final _barColor = PinkColors.shade900;
  static final _gridLineColor = PinkColors.shade200;
  static final _labelColor = PinkColors.shade800;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Setup ──────────────────────────────────────────────────────────────────

  Future<void> _setup() async {
    await _fetchData();
    _scrollController = ScrollController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToCurrentMonth());
  }

  Future<void> _fetchData() async {
    final data = await EntryProvider().getMonthlyCounts();
    final maxVal = data.values.toList().max.toDouble();
    setState(() {
      _monthlyData = _convertToBarData(data);
      _maxValue = maxVal + min(50, (maxVal * 0.5).ceil());
      _isLoading = false;
    });
  }

  List<BarData> _convertToBarData(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();
    return sortedKeys
        .map((key) => BarData(label: key, value: (data[key] ?? 0).toDouble()))
        .toList();
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients) return;
    final monthsFromEnd = 12 - DateTime.now().month + _scrollToMonthsFromEnd;
    final targetIndex = _monthlyData.length - monthsFromEnd;
    final barRightEdge = (targetIndex + 1) * (_barWidth + _barSpacing) + 14.5;
    final viewportWidth = _scrollController.position.viewportDimension;
    final offset = (barRightEdge - viewportWidth).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(offset);
  }

  // ─── Interaction ────────────────────────────────────────────────────────────

  int? _indexFromX(double x) {
    final contentX = x + _scrollController.offset;
    for (int i = 0; i < _monthlyData.length; i++) {
      final barLeft = _barSpacing + i * (_barWidth + _barSpacing);
      if (contentX >= barLeft && contentX <= barLeft + _barWidth) return i;
    }
    return null;
  }

  void _onTapDown(TapDownDetails details) {
    final tapped = _indexFromX(details.localPosition.dx);
    setState(() => _selectedIndex = tapped == _selectedIndex ? null : tapped);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moments per Month',
          style: TextStyle(
            color: PinkColors.shade900,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: _chartHeight + BarChart.xAxisHeight,
          child: _isLoading ? const CircularProgressIndicator() : _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYAxisLabel(),
        _buildYAxis(),
        Expanded(child: _buildScrollableArea()),
      ],
    );
  }

  Widget _buildYAxisLabel() {
    return SizedBox(
      width: 16,
      height: _chartHeight,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            '# Entries',
            style: TextStyle(color: _barColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildYAxis() {
    return SizedBox(
      width: BarChart.yAxisWidth,
      height: _chartHeight,
      child: CustomPaint(
        painter: YAxisPainter(
          maxValue: _maxValue,
          divisions: _yDivisions,
          labelColor: _labelColor,
        ),
      ),
    );
  }

  Widget _buildScrollableArea() {
    return ClipRect(
      child: GestureDetector(
        onTapDown: _onTapDown,
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width:
                _monthlyData.length * (_barWidth + _barSpacing) + _barSpacing,
            height: _chartHeight + BarChart.xAxisHeight,
            child: CustomPaint(
              painter: BarChartPainter(
                data: _monthlyData,
                maxValue: _maxValue,
                divisions: _yDivisions,
                barWidth: _barWidth,
                barSpacing: _barSpacing,
                chartHeight: _chartHeight,
                xAxisHeight: BarChart.xAxisHeight,
                barColor: _barColor,
                gridLineColor: _gridLineColor,
                labelColor: _labelColor,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── YAxisPainter ─────────────────────────────────────────────────────────────

class YAxisPainter extends CustomPainter {
  final double maxValue;
  final int divisions;
  final Color labelColor;

  const YAxisPainter({
    required this.maxValue,
    required this.divisions,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: labelColor,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= divisions; i++) {
      final value = (maxValue / divisions) * i;
      final y = size.height - (size.height * i / divisions);
      final textPainter = TextPainter(
        text: TextSpan(text: _formatValue(value), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: BarChart.yAxisWidth - 8);

      textPainter.paint(
        canvas,
        Offset(
          BarChart.yAxisWidth - textPainter.width - 8,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  String _formatValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }
    return value.toInt().toString();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── BarChartPainter ──────────────────────────────────────────────────────────

class BarChartPainter extends CustomPainter {
  final List<BarData> data;
  final double maxValue;
  final int divisions;
  final double barWidth;
  final double barSpacing;
  final double chartHeight;
  final double xAxisHeight;
  final Color barColor;
  final Color gridLineColor;
  final Color labelColor;
  final int? selectedIndex;

  static const double _tooltipPadding = 8.0;
  static const double _tooltipArrowHeight = 6.0;
  static const double _tooltipRadius = 6.0;
  static const double _tooltipGap = 6.0;
  static const double _rotationAngle = -75 * (3.141592653589793 / 180);

  const BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.divisions,
    required this.barWidth,
    required this.barSpacing,
    required this.chartHeight,
    required this.xAxisHeight,
    required this.barColor,
    required this.gridLineColor,
    required this.labelColor,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGridLines(canvas, size);
    _drawBars(canvas);
    _drawXLabels(canvas);
    if (selectedIndex != null) {
      _drawTooltip(canvas, size, selectedIndex!);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter old) =>
      old.selectedIndex != selectedIndex;

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= divisions; i++) {
      final y = chartHeight - (chartHeight * i / divisions);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawBars(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final barHeight = (item.value / maxValue) * chartHeight;
      final x = barSpacing + i * (barWidth + barSpacing);
      final y = chartHeight - barHeight;
      final isSelected = i == selectedIndex;

      final topColor = isSelected ? barColor.withValues(alpha: 1) : barColor;
      final bottomColor = isSelected
          ? barColor.withValues(alpha: 0.9)
          : barColor.withValues(alpha: 0.5);

      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  void _drawXLabels(Canvas canvas) {
    for (int i = 0; i < data.length; i++) {
      final x = barSpacing + i * (barWidth + barSpacing);
      final centerX = x + barWidth / 2;
      final isSelected = i == selectedIndex;

      final color = isSelected
          ? barColor.withValues(alpha: 1)
          : (selectedIndex == null
              ? labelColor
              : labelColor.withValues(alpha: 0.6));

      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatLabel(data[i].label),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(centerX, chartHeight + 10);
      canvas.rotate(_rotationAngle);
      textPainter.paint(
          canvas, Offset(-textPainter.width, -textPainter.height / 2));
      canvas.restore();
    }
  }

  void _drawTooltip(Canvas canvas, Size size, int index) {
    final item = data[index];
    final barHeight = (item.value / maxValue) * chartHeight;
    final x = barSpacing + index * (barWidth + barSpacing);
    final barTopY = chartHeight - barHeight;
    final barCenterX = x + barWidth / 2;

    final label = item.value >= 1000
        ? '${(item.value / 1000).toStringAsFixed(1)}k'
        : item.value.toInt().toString();

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: PinkColors.shade100,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tooltipWidth = textPainter.width + _tooltipPadding * 2;
    final tooltipHeight = textPainter.height + _tooltipPadding * 2;
    final tooltipLeft =
        (barCenterX - tooltipWidth / 2).clamp(0.0, size.width - tooltipWidth);
    final tooltipTop =
        barTopY - tooltipHeight - _tooltipArrowHeight - _tooltipGap;
    final tooltipRect =
        Rect.fromLTWH(tooltipLeft, tooltipTop, tooltipWidth, tooltipHeight);

    final bgPaint = Paint()..color = PinkColors.shade900;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          tooltipRect, const Radius.circular(_tooltipRadius)),
      bgPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(barCenterX - 6, tooltipTop + tooltipHeight)
        ..lineTo(barCenterX, tooltipTop + tooltipHeight + _tooltipArrowHeight)
        ..lineTo(barCenterX + 6, tooltipTop + tooltipHeight)
        ..close(),
      bgPaint,
    );

    textPainter.paint(
      canvas,
      Offset(tooltipLeft + _tooltipPadding, tooltipTop + _tooltipPadding),
    );
  }

  String _formatLabel(String rawLabel) {
    final parts = rawLabel.split('-');
    final monthInt = int.parse(parts.last);
    return monthInt == 1 ? '${parts.first} - 1' : '$monthInt';
  }
}
