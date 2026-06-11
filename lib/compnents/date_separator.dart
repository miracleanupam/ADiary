import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class DateSeparator extends StatelessWidget {
  final String date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DateSeparatorDecor(),
          Text(
            date,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: PinkColors.shade700,
                fontSize: 16),
          ),
          Expanded(
              child: DateSeparatorLine(
            color: PinkAccentColors.shade200,
            thickness: 2,
          )),
        ],
      ),
    );
  }
}

class DateSeparatorLine extends StatelessWidget {
  final Color color;
  final double thickness;

  const DateSeparatorLine({
    super.key,
    required this.color,
    this.thickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(color: color, thickness: thickness),
      size: Size(double.infinity, thickness),
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  const _LinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(8, 0, size.width, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || old.thickness != thickness;
}

class DateSeparatorDecor extends StatelessWidget {
  const DateSeparatorDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: DateSeparatorPainter(),
      ),
    );
  }
}

class DateSeparatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 8.0;
    final dotCenter = Offset(size.width / 2, size.height / 2);
    final dotRect = Rect.fromCircle(center: dotCenter, radius: dotRadius);
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          PinkAccentColors.shade200, // center — lighter
          PinkAccentColors.shade400, // edge — darker
        ],
      ).createShader(dotRect);
    canvas.drawCircle(dotCenter, dotRadius, radialPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
