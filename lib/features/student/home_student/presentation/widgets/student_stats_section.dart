import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/extensions/translation_extension.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_icons.dart';

class StudentStatsSection extends StatelessWidget {
  final int views;
  final int jobApplicationsCount;
  final int approvedJobApplicationsCount;

  const StudentStatsSection({
    super.key,
    required this.views,
    required this.jobApplicationsCount,
    required this.approvedJobApplicationsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatCard(
          iconPath: AppIcons.views,
          label: 'home_views'.trOrFallback('Views'),
          value: views.toString(),
        ),
        10.width,
        _StatCard(
          iconPath: AppIcons.requests,
          label: 'home_requests'.trOrFallback('Requests'),
          value: jobApplicationsCount.toString(),
        ),
        10.width,
        _StatCard(
          iconPath: AppIcons.applied,
          label: 'home_applied'.trOrFallback('Applied'),
          value: approvedJobApplicationsCount.toString(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const _StatCard({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102.w,
      height: 100.h,
      padding: EdgeInsets.only(
        top: 9.h,
        right: 18.w,
        bottom: 9.h,
        left: 18.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
         
            child: Center(
              child: iconPath.endsWith('.svg')
                  ? SvgImageWidget(
                      image: iconPath,
                      width: 50.w,
                      height: 50.h,
                      colorFilter: ColorFilter.mode(
                        AppColors.secondaryColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Image.asset(
                      iconPath,
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          6.height,
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.lightTText,
              fontWeight: FontWeight.w700,
              fontFamily: 'Tajawal',
              height: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          2.height,
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'Tajawal',
              color: AppColors.secondaryColor,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

