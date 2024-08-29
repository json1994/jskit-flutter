import 'dart:ui';
import 'package:flutter/material.dart';

class EnhancedBlurAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget child;
  final Color backgroundColor;
  final double blurSigma;
  final Duration animationDuration;

  const EnhancedBlurAppBar({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.black45,
    this.blurSigma = 10,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<EnhancedBlurAppBar> createState() => _EnhancedBlurAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _EnhancedBlurAppBarState extends State<EnhancedBlurAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _blurAnimation = Tween<double>(begin: 0, end: widget.blurSigma).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollNotificationObserver.of(context).addListener(_handleScrollNotification);
  }

  @override
  void dispose() {
    ScrollNotificationObserver.of(context).removeListener(_handleScrollNotification);
    _animationController.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      final bool isScrolled = notification.metrics.pixels > 0;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
          if (_isScrolled) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: widget.backgroundColor.withOpacity(_animationController.value),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: child,
            ),
          ),
        );
      },
      child: SafeArea(
        top: true,
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: widget.child,
        ),
      ),
    );
  }
}