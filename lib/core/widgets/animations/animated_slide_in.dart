import 'package:flutter/material.dart';

class AnimatedSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationController controller;
  final double startOffset;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    required this.index,
    required this.controller,
    this.startOffset = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final animation =
        Tween<Offset>(begin: Offset(0, startOffset), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              (0.6 + (index * 0.1)).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          (0.6 + (index * 0.1)).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(
      opacity: opacityAnimation,
      child: SlideTransition(position: animation, child: child),
    );
  }
}
