import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../core/app_config/app_colors.dart';

class AnimatedLoading extends StatefulWidget {
  final double? size;
  final Color? color;

  const AnimatedLoading({super.key, this.size, this.color});

  @override
  State<AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<AnimatedLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 40.r;
    final color = widget.color ?? AppColors.primaryColor;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Main circular path
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      animation: _animation,
                      color: color,
                    ),
                  ),
                ),
                // Inner rotating dots
                ..._buildRotatingDots(size, color),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildRotatingDots(double size, Color color) {
    final dotSize = size * 0.12;
    final radius = size * 0.28;

    return List.generate(3, (index) {
      final angle =
          (_animation.value * 2 * math.pi) + (index * 2 * math.pi / 3);
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      return Transform.translate(
        offset: Offset(x, y),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width:
              dotSize *
              (0.8 +
                  (_animation.value * 0.4 * (index % 2 == 0 ? 1 : -1)).abs()),
          height:
              dotSize *
              (0.8 +
                  (_animation.value * 0.4 * (index % 2 == 0 ? -1 : 1)).abs()),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7 + (_animation.value * 0.3)),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class _CircularProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _CircularProgressPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.r
      ..strokeCap = StrokeCap.round;

    // Draw the animated arc
    final sweepAngle = 2 * math.pi * (0.6 + animation.value * 0.3);
    final startAngle = animation.value * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw the lighter background arc
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.r;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
