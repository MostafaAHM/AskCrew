import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// About section with description and rating
class AboutSectionWidget extends StatelessWidget {
  final String about;
  final double? rating;

  const AboutSectionWidget({super.key, required this.about, this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'About'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.lightMainText,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            if (rating != null) ...[
              Icon(Icons.star, color: Colors.orange, size: 18.sp),
              4.width,
              Text(
                rating!.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightMainText,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ],
        ),
        15.height,
        if (about.isNotEmpty)
          Text(
            about,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightSecMainText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
      ],
    );
  }
}
