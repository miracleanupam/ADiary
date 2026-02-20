import 'package:flutter/material.dart';

class AnimatedCloseButton extends StatefulWidget {
  final double top;
  final double right;
  final Function fn;
  static void _defaultFn() {}

  const AnimatedCloseButton({
    super.key,
    required this.top,
    required this.right,
    this.fn = _defaultFn,
  });

  @override
  State<AnimatedCloseButton> createState() => _AnimatedCloseButtonState();
}

class _AnimatedCloseButtonState extends State<AnimatedCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )
      ..repeat(reverse: true)
      ..addListener(() {});
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
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
                border: Border.all(color: Colors.pink.shade600),
                color: Colors.pink.shade200,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.pink.shade600,
                  ),
                ),
              )),
        ));
  }
}
