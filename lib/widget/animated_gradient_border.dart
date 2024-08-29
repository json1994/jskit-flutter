import 'package:flutter/material.dart';
import 'dart:math' as math;
/*
AnimatedGradientBorder(
  gradientColors: [Colors.blue, Colors.purple, Colors.red],
  borderWidth: 3.0,
  borderRadius: 12.0,
  animate: true,
  animationDuration: Duration(seconds: 3),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text('Hello, Animated Gradient Border!'),
  ),
)
 */
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;
  final bool animate;
  final Duration animationDuration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderWidth = 2.0,
    this.borderRadius = 8.0,
    this.animate = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  _AnimatedGradientBorderState createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientBorderPainter(
        gradientColors: widget.gradientColors,
        borderWidth: widget.borderWidth,
        borderRadius: widget.borderRadius,
        animation: _controller,
      ),
      child: Container(
        padding: EdgeInsets.all(widget.borderWidth),
        child: widget.child,
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;
  final Animation<double> animation;

  GradientBorderPainter({
    required this.gradientColors,
    required this.borderWidth,
    required this.borderRadius,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        tileMode: TileMode.repeated,
        transform: GradientRotation(animation.value * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradientColors != gradientColors;
  }
}