import 'package:adiary/models/entry.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BarData {
  final String label;
  final double value;

  const BarData({required this.label, required this.value});
}

class BarChart extends StatefulWidget {
  const BarChart({
    super.key,
  });

  // Fixed left width for y-axis labels
  static const double yAxisWidth = 32.0;
  // Bottom height for x-axis labels
  static const double xAxisHeight = 64.0;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  bool isLoading = true;
  double maxValue = 0;
  late List<BarData> monthlyData;
  late final ScrollController _scrollController;
  int? _selectedIndex;

  static const double barWidth = 10;
  static const double barSpacing = 19.5;
  static const int yDivisions = 5;
  static const double chartHeight = 300;
  static Color barColor = Colors.pink.shade900;
  static Color gridLineColor = Colors.pink.shade200;
  static Color labelColor = Colors.pink.shade800;
  static double scrollTo = 12 - DateTime.now().month + 1;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _fetchData();
    _scrollController = ScrollController();

    // After the first frame, the scroll view has been laid out and
    // maxScrollExtent is available — jump straight to the end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final targetIndex = monthlyData.length - scrollTo;

      // Right edge of the target bar in the scroll content's coordinate space
      final barRightEdge = (targetIndex + 1) * (barWidth + barSpacing);

      // Viewport width (the visible area, excluding the fixed Y-axis)
      final viewportWidth = _scrollController.position.viewportDimension;

      // Scroll so that bar's right edge sits at the viewport's right edge
      final scrollToClamped = (barRightEdge - viewportWidth).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(scrollToClamped);
    });
  }

  Future<void> _fetchData() async {
    final data = await EntryProvider().getMonthlyCounts();
    setState(() {
      monthlyData = convertToBarData(data);
      isLoading = false;
      maxValue = data.values.toList().max.toDouble();
    });
  }

  List<BarData> convertToBarData(Map<String, int> data) {
    final sortedKeys = data.keys.toList()..sort();

    return sortedKeys.map((key) {
      return BarData(
        label: key,
        value: (data[key] ?? 0).toDouble(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Convert a tap's local x (within the visible viewport) to a bar index.
  // We add the scroll offset to get the position within the full content.
  int? _indexFromX(double x) {
    final contentX = x + _scrollController.offset;
    for (int i = 0; i < monthlyData.length; i++) {
      final barLeft = barSpacing + i * (barWidth + barSpacing);
      final barRight = barLeft + barWidth;
      if (contentX >= barLeft && contentX <= barRight) return i;
    }
    return null;
  }

  void _onTapDown(TapDownDetails details) {
    final tappedIndex = _indexFromX(details.localPosition.dx);
    setState(() {
      // Tapping the same bar again deselects it.
      _selectedIndex = tappedIndex == _selectedIndex ? null : tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Moments per Month", style: TextStyle(
          color: Colors.pink.shade900,
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),),
        SizedBox(height: 32,),
        SizedBox(
            height: chartHeight + BarChart.xAxisHeight,
            child: isLoading
                ? CircularProgressIndicator()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 16,
                        height: chartHeight,
                        child: Center(
                          child: RotatedBox(
                            quarterTurns:
                                3, // 270deg so text reads bottom-to-top
                            child: Text(
                              "# Entries",
                              style: TextStyle(
                                  color: barColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      // Fixed Y-axis labels column
                      SizedBox(
                        width: BarChart.yAxisWidth,
                        height: chartHeight,
                        child: CustomPaint(
                          painter: YAxisPainter(
                            maxValue: maxValue,
                            divisions: yDivisions,
                            labelColor: labelColor,
                          ),
                        ),
                      ),
            
                      // Scrollable bars area
                      Expanded(
                        child: ClipRect(
                          child: GestureDetector(
                            onTapDown: _onTapDown,
                            behavior: HitTestBehavior.opaque,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: monthlyData.length *
                                        (barWidth + barSpacing) +
                                    barSpacing,
                                height: chartHeight + BarChart.xAxisHeight,
                                child: CustomPaint(
                                  painter: BarChartPainter(
                                      data: monthlyData,
                                      maxValue: maxValue,
                                      divisions: yDivisions,
                                      barWidth: barWidth,
                                      barSpacing: barSpacing,
                                      chartHeight: chartHeight,
                                      xAxisHeight: BarChart.xAxisHeight,
                                      barColor: barColor,
                                      gridLineColor: gridLineColor,
                                      labelColor: labelColor,
                                      selectedIndex: _selectedIndex),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
      ],
    );
  }
}

class YAxisPainter extends CustomPainter {
  final double maxValue;
  final int divisions;
  final Color labelColor;

  YAxisPainter({
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

      final label = _formatValue(value);
      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
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

  BarChartPainter({
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
    _drawBars(canvas, size);
    _drawXLabels(canvas, size);
    if (selectedIndex != null) _drawTooltip(canvas, size, selectedIndex!);
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex;

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

  void _drawBars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final barHeight = (item.value / maxValue) * chartHeight;
      final x = barSpacing + i * (barWidth + barSpacing);
      final y = chartHeight - barHeight;

      final isSelected = i == selectedIndex;

      // Draw bar with rounded top corners
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final Color topColor;
      final Color bottomColor;

      if (isSelected) {
        topColor = barColor.withValues(alpha: 1);
        bottomColor = barColor.withValues(alpha: 0.9);
      } else {
        topColor = barColor;
        bottomColor = barColor.withValues(alpha: 0.5);
      }

      // Gradient for bar
      final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor]);

      paint.shader = gradient.createShader(
        Rect.fromLTWH(x, y, barWidth, barHeight),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  void _drawXLabels(Canvas canvas, Size size) {
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = barSpacing + i * (barWidth + barSpacing);
      final centerX = x + barWidth / 2;

      final isSelected = i == selectedIndex;
      final color = isSelected
          ? barColor.withValues(alpha: 1)
          : (selectedIndex == null
              ? labelColor
              : labelColor.withValues(alpha: 0.6));
      final textStyle = TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

      final textSpan = TextSpan(
        text: formatLabels(item.label),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Pivot point: horizontally centered under the bar, vertically at label start
      final pivotX = centerX;
      final pivotY = chartHeight + 10;

      canvas.save();
      canvas.translate(pivotX, pivotY);
      canvas.rotate(-75 * (3.141592653589793 / 180)); // -45 degrees
      // After rotation, offset so text is right-aligned to the pivot
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

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.pink.shade100,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    const padding = 8.0;
    const arrowHeight = 6.0;
    final tooltipWidth = textPainter.width + padding * 2;
    final tooltipHeight = textPainter.height + padding * 2;
    const tooltipRadius = 6.0;
    const gap = 6.0;

    double tooltipLeft = barCenterX - tooltipWidth / 2;
    tooltipLeft = tooltipLeft.clamp(0.0, size.width - tooltipWidth);
    final tooltipTop = barTopY - tooltipHeight - arrowHeight - gap;

    final tooltipRect =
        Rect.fromLTWH(tooltipLeft, tooltipTop, tooltipWidth, tooltipHeight);

    final bgPaint = Paint()..color = Colors.pink.shade900;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          tooltipRect, const Radius.circular(tooltipRadius)),
      bgPaint,
    );

    final arrowPath = Path()
      ..moveTo(barCenterX - 6, tooltipTop + tooltipHeight)
      ..lineTo(barCenterX, tooltipTop + tooltipHeight + arrowHeight)
      ..lineTo(barCenterX + 6, tooltipTop + tooltipHeight)
      ..close();
    canvas.drawPath(arrowPath, bgPaint);

    textPainter.paint(
      canvas,
      Offset(tooltipLeft + padding, tooltipTop + padding),
    );
  }

  String formatLabels(String rawLabel) {
    final splits = rawLabel.split('-');
    final year = splits.first;
    final month = splits.last;
    final monthInt = int.parse(month);
    if (monthInt == 1) {
      return '$year-1';
    }
    return '$monthInt';
  }
}
