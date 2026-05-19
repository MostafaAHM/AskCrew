import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/app_config/app_colors.dart';

class RatingRow extends StatelessWidget {
  final double rating;

  const RatingRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(
                Icons.star_rounded,
                color: AppColors.secondaryColor,
                size: 18.sp,
              );
            } else if (index < rating && (rating - index) >= 0.5) {
              return Icon(
                Icons.star_half_rounded,
                color: AppColors.secondaryColor,
                size: 18.sp,
              );
            } else {
              return Icon(
                Icons.star_outline_rounded,
                color: const Color(0xFFD9D9D9),
                size: 18.sp,
              );
            }
          }),
        ),
        8.horizontalSpace,
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
