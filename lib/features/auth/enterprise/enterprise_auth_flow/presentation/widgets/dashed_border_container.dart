import 'package:aflam/core/app_config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: borderColor ?? AppColors.borderColor,
        strokeWidth: borderWidth ?? 1.5,
        borderRadius: borderRadius ?? 8.r,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding ?? EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.lightBGColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Create dashed effect
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final path = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(path, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
