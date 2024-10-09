import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBlurAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomBlurAppBar({super.key, this.title, this.actions});
  final Widget? title;
  final Widget? actions;
  @override
  State<CustomBlurAppBar> createState() => _CustomBlurAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomBlurAppBarState extends State<CustomBlurAppBar> {
  ScrollNotificationObserverState? _notificationObserverState;
  bool _scrollerUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notificationObserverState != null) {
      _notificationObserverState?.removeListener(_handleScrollNotification);
    }
    _notificationObserverState = ScrollNotificationObserver.of(context);
    if (_notificationObserverState != null) {
      _notificationObserverState?.addListener(_handleScrollNotification);
    }
  }

  @override
  void dispose() {
    if (_notificationObserverState != null) {
      _notificationObserverState?.removeListener(_handleScrollNotification);
      _notificationObserverState = null;
    }
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollUpdateNotification) {
      if (scrollNotification.depth != 0) return;
      final bool oldScrollUnder = _scrollerUnder;
      final metrics = scrollNotification.metrics;
      switch (metrics.axisDirection) {
        case AxisDirection.up:
          _scrollerUnder = metrics.extentAfter > 0;
          break;
        case AxisDirection.down:
          _scrollerUnder = metrics.extentBefore > 0;
          break;
        case AxisDirection.right:
        case AxisDirection.left:
          break;
      }
      if (_scrollerUnder != oldScrollUnder) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: SizedBox(height: kToolbarHeight, child: Stack(fit: StackFit.expand, children: [
        widget.title ?? Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            )
          ],
        ),
        if (widget.actions != null)
          Align(
            alignment: Alignment.centerRight,
            child: widget.actions,
          )
      ],),),
    );
    if (_scrollerUnder) {
      content = Container(
        color: Colors.black45,
        child: ClipRect(child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: content,
        ),),

      );
    }
    return content;
  }
}
class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  final double max;
  final double min;
  final Widget Function(BuildContext context, double offset) builder;

  PersistentHeaderBuilder(
      {this.max = 120, this.min = 80, required this.builder})
      : assert(max >= min);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) =>
      max != oldDelegate.max ||
          min != oldDelegate.min ||
          builder != oldDelegate.builder;
}