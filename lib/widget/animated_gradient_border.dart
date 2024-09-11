import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientBorder extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;

  const GradientBorder({
    Key? key,
    required this.child,
    required this.gradientColors,
    this.borderWidth = 2.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientBorderPainter(
        gradientColors: gradientColors,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double borderWidth;
  final double borderRadius;

  GradientBorderPainter({
    required this.gradientColors,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final smoothGradient = _createSmoothGradient(gradientColors);

    final shader = SweepGradient(
      colors: smoothGradient,
      stops: _calculateGradientStops(smoothGradient.length),
      startAngle: 0,
      endAngle: math.pi * 2,
      tileMode: TileMode.clamp,
    ).createShader(rect);

    paint.shader = shader;

    canvas.drawRRect(rRect, paint);
  }

  List<Color> _createSmoothGradient(List<Color> colors) {
    List<Color> smoothColors = [];
    for (int i = 0; i < colors.length; i++) {
      smoothColors.add(colors[i]);
      if (i < colors.length - 1) {
        smoothColors.add(Color.lerp(colors[i], colors[(i + 1) % colors.length], 0.5)!);
      }
    }
    smoothColors.add(colors.first);
    return smoothColors;
  }

  List<double> _calculateGradientStops(int colorCount) {
    return List<double>.generate(colorCount, (index) => index / (colorCount - 1));
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradientColors != gradientColors;
  }
}