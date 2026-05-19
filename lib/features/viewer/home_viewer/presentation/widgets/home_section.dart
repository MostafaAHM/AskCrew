import 'package:aflam/core/app_config/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/app_config/app_colors.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeMoreTap;
  final Widget child;

  const HomeSection({
    super.key,
    required this.title,
    this.onSeeMoreTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.lightTText,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (onSeeMoreTap != null)
              GestureDetector(
                onTap: onSeeMoreTap,
                child: Text(
                  AppStrings.seeMore.tr(),
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}
