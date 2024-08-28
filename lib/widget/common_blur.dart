import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedGlass extends StatelessWidget {
  final Widget? bg;
  final double blurX;
  final double blurY;
  final Color color;
  final double opacity;
  final Widget? child;

  const FrostedGlass({
    super.key,
    this.bg,
    this.child,
    this.blurX = 10.0,
    this.blurY = 10.0,
    this.color = Colors.white,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: Stack(
      children: [
        // 背景图像层
        Positioned.fill(
          child: bg ?? DecoratedBox(decoration: BoxDecoration(color: color.withOpacity(0.4))),
        ),
        // 毛玻璃效果层
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
            child: Container(
              color: color.withOpacity(opacity),
              child: child,
            ),
          ),
        ),
      ],
    ),);
  }
}
