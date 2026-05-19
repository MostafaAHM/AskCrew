import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionSelectionShimmer extends StatelessWidget {
  const SubscriptionSelectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [_durationRow(), 32.height, _plansCard()]),
    );
  }

  Widget _durationRow() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 36.h,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8.w),
            decoration: BoxDecoration(
              color: AppColors.lightBGColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      }),
    );
  }

  Widget _plansCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: List.generate(3, (index) {
          return Column(
            children: [
              _planItem(),
              if (index != 2)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Divider(color: AppColors.borderColor, height: 1),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _planItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18.h,
          width: 140.w,
          decoration: BoxDecoration(
            color: AppColors.lightBGColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        12.height,
        Container(
          height: 14.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: AppColors.lightBGColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        16.height,
        ...List.generate(3, (_) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  width: 18.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightBGColor,
                    shape: BoxShape.circle,
                  ),
                ),
                12.width,
                Expanded(
                  child: Container(
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightBGColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
