import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class AnimatedCloseButton extends StatefulWidget {
  final double top;
  final double right;
  final Function fn;

  const AnimatedCloseButton({
    super.key,
    required this.top,
    required this.right,
    this.fn = _noOp,
  });

  static void _noOp() {}

  @override
  State<AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<AnimatedCloseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      right: widget.right,
      child: GestureDetector(
        onTap: () => widget.fn(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PinkColors.shade200,
            border: Border.all(color: PinkColors.shade600),
          ),
          padding: const EdgeInsets.all(4.0),
          child: ScaleTransition(
            scale: _pulse,
            child: Icon(Icons.close, size: 12, color: PinkColors.shade600),
          ),
        ),
      ),
    );
  }
}