import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/core/extensions/space_extension.dart';

class RewardsScreenShimmer extends StatelessWidget {
  const RewardsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card Shimmer
          CustomShimmerWidget(
            height: 180.h,
            width: double.infinity,
            radius: 28.r,
          ),
          (32).height,
          // Tabs Shimmer
          Row(
            children: [
              Expanded(
                child: CustomShimmerWidget(height: 48.h, radius: 12.r),
              ),
              (12).width,
              Expanded(
                child: CustomShimmerWidget(height: 48.h, radius: 12.r),
              ),
            ],
          ),
          (32).height,
          // List Title Shimmer
          CustomShimmerWidget(height: 30.h, width: 200.w, radius: 4.r),
          (24).height,
          // Activity Cards Shimmer
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: CustomShimmerWidget(
                height: 100.h,
                width: double.infinity,
                radius: 28.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
