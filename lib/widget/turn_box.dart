import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TurnBoxController extends ValueNotifier<bool> {
  TurnBoxController(super.value, {this.from});
  double? from;
  void forward({double? from}) {
    this.from = from;
    value = true;
  }

  void reverse({double? from}) {
    this.from = from;
    value = false;
  }
}

/// Animates the rotation of a widget when [turns]  is changed.
class TurnBox extends StatefulWidget {
  const TurnBox({
    Key? key,
    this.turns = .0,
    this.speed = 200,
    this.controller,
    required this.child,
  }) : super(key: key);

  /// Controls the rotation of the child.
  ///
  /// If the current value of the turns is v, the child will be
  /// rotated v * 2 * pi radians before being painted.
  final double turns;

  /// Animation duration in milliseconds
  final int speed;

  final Widget child;

  final TurnBoxController? controller;
  @override
  _TurnBoxState createState() => _TurnBoxState();
}

class _TurnBoxState extends State<TurnBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  TurnBoxController? _boxController;
  set boxController(TurnBoxController? controller) {
    _boxController?.removeListener(_valueChange);
    _boxController = controller;
    _boxController?.addListener(_valueChange);
  }

  void _valueChange() {
    if (_boxController?.value == true) {
      _controller.forward(from: _boxController?.from);
    } else {
      _controller.reverse(from: _boxController?.from);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    boxController = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * widget.turns,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(TurnBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_boxController != widget.controller) {
      boxController = widget.controller;
    }
    if (oldWidget.turns != widget.turns) {
      _controller.value = widget.turns;
    }
  }
}
