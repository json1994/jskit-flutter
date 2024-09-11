import 'dart:ui';
import 'package:flutter/material.dart';

class Vitrify extends StatefulWidget {
  final Widget child;
  final double opacity;
  final BorderRadius? radius;
  final Color color;
  final bool animate;
  final Duration animationDuration;

  const Vitrify({
    super.key,
    required this.child,
    this.opacity = 0.4,
    this.radius,
    this.color = Colors.white,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  _VitrifyState createState() => _VitrifyState();
}

class _VitrifyState extends State<Vitrify> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: widget.opacity).animate(_controller);
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Vitrify oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opacity != widget.opacity) {
      _opacityAnimation = Tween<double>(begin: 0.0, end: widget.opacity).animate(_controller);
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double sigma = widget.animate ? _controller.value * 5 : 5;
        return ClipRRect(
          borderRadius: widget.radius ?? BorderRadius.circular(5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: widget.child,
          ),
        );
      },
    );
  }
}
