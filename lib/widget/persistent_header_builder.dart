import 'package:flutter/material.dart';

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
    // print(shrinkOffset);
    // if (shrinkOffset > max - min) {
    //   shrinkOffset = max - min;
    // }
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
