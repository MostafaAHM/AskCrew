import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'shimmer_box.dart';

class CompanyInfoStepShimmer extends StatelessWidget {
  const CompanyInfoStepShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.height,
          const ShimmerBox(height: 24, width: 220, borderRadius: 6),
          8.height,
          const ShimmerBox(height: 16, width: 260, borderRadius: 6),
          32.height,
          const ShimmerBox(height: 16, width: 120, borderRadius: 6),
          10.height,
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.centerLeft,
            child: const ShimmerBox(height: 14, width: 180, borderRadius: 4),
          ),
          20.height,
          const ShimmerBox(height: 16, width: 120, borderRadius: 6),
          10.height,
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.centerLeft,
            child: const ShimmerBox(height: 14, width: 160, borderRadius: 4),
          ),
          32.height,
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.lightBGColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                const ShimmerBox(height: 14, width: 210, borderRadius: 4),
                8.height,
                const ShimmerBox(height: 12, width: 180, borderRadius: 4),
                16.height,
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const ShimmerBox(
                    height: 20,
                    width: 20,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ),
          32.height,
          const ShimmerBox(height: 16, width: 100, borderRadius: 6),
          8.height,
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                const ShimmerBox(height: 14, width: 120, borderRadius: 4),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.secondaryColor.withOpacity(0.4),
                  size: 24.sp,
                ),
              ],
            ),
          ),
          24.height,
        ],
      ),
    );
  }
}
