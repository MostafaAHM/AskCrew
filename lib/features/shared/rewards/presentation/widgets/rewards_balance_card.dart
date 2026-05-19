import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RewardsBalanceCard extends StatelessWidget {
  final int totalPoints;
  final int nextLevelPoints;

  const RewardsBalanceCard({
    super.key,
    required this.totalPoints,
    required this.nextLevelPoints,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (totalPoints / nextLevelPoints).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xffFFFBF7),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: const Color(0xffFE5B00).withOpacity(0.6),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFE5B00).withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events_outlined,
                    color: const Color(0xffFE5B00),
                    size: 30.sp,
                  ),
                ),
              ),
              (16).width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.rewardsGlobalBalance.tr(),
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff1A1A1A),
                        fontFamily: 'Tajawal',
                        height: 1.2,
                      ),
                    ),
                    (2).height,
                    Text(
                      AppStrings.rewardsEarnedPoints.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xff9A9A9A),
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalPoints',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffFE5B00),
                      fontFamily: 'Tajawal',
                      height: 1.1,
                    ),
                  ),
                  Text(
                    AppStrings.points.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xff9A9A9A),
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          (28).height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.rewardsProgressNextLevel.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xff9A9A9A),
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$totalPoints / $nextLevelPoints',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFE5B00),
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          (12).height,
          Container(
            height: 14.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffFDE7D8),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffFE5B00),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
