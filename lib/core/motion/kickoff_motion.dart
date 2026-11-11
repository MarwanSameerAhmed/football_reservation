import 'package:flutter/material.dart';

/// Shared motion tokens for calm, responsive, and accessible interactions.
abstract final class KickoffMotion {
  static const Duration press = Duration(milliseconds: 120);
  static const Duration stateChange = Duration(milliseconds: 200);
  static const Duration controlGlide = Duration(milliseconds: 380);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration section = Duration(milliseconds: 400);

  static const double pressedScale = 0.975;

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Cubic(0.16, 1, 0.3, 1);

  static Duration accessible(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Adds restrained, tactile press feedback without owning the tap gesture.
class KickoffPressable extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const KickoffPressable({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<KickoffPressable> createState() => _KickoffPressableState();
}

class _KickoffPressableState extends State<KickoffPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? KickoffMotion.pressedScale : 1.0,
        duration: KickoffMotion.accessible(context, KickoffMotion.press),
        curve: KickoffMotion.standard,
        child: widget.child,
      ),
    );
  }
}

/// Smooth staggered fade + slight upward slide reveal for hero & section cards.
class KickoffMotionReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double verticalOffset;

  const KickoffMotionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.verticalOffset = 12.0,
  });

  @override
  State<KickoffMotionReveal> createState() => _KickoffMotionRevealState();
}

class _KickoffMotionRevealState extends State<KickoffMotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: KickoffMotion.section,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: KickoffMotion.emphasized,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final v = _animation.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.verticalOffset * (1 - v)),
            child: child,
          ),
        );
      },
    );
  }
}
