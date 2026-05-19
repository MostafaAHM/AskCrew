import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../data/models/user_stats_model.dart';

class UserStatsSection extends StatelessWidget {
  final UserStatsModel stats;
  const UserStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopStatsCard(stats: stats),
        18.verticalSpace,
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                titleKey: 'rentalProducts',
                value: stats.totalRentedProducts.toString(),
                icon: IconlyLight.bag,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                titleKey: 'chats',
                value: stats.totalChatRooms.toString(),
                icon: IconlyLight.chat,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MiniStatCard(
                titleKey: 'myProducts',
                value: stats.totalProductsForRent.toString(),
                icon: IconlyLight.category,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopStatsCard extends StatelessWidget {
  final UserStatsModel stats;
  const _TopStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFFE5B00);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.w),
          left: BorderSide(color: borderColor, width: 1.w),
          right: BorderSide(color: borderColor, width: 1.w),
          bottom: BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TopStatItem(
              titleKey: 'completedWorkshops',
              value: stats.totalCompletedWorkshops.toString(),
              icon: IconlyLight.folder,
            ),
          ),
          Container(width: 1.5, height: 56.h, color: borderColor),
          Expanded(
            child: _TopStatItem(
              titleKey: 'ratings',
              value: stats.meanRating.toStringAsFixed(1),
              icon: IconlyLight.star,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatItem extends StatelessWidget {
  final String titleKey;
  final String value;
  final IconData icon;

  const _TopStatItem({
    required this.titleKey,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleKey.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF8A8A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          14.verticalSpace,
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor.withOpacity(0.12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              10.horizontalSpace,
              Text(
                value,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String titleKey;
  final String value;
  final IconData icon;

  const _MiniStatCard({
    required this.titleKey,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border(
          top: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          right: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          bottom: BorderSide.none,
          left: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF8A8A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          12.verticalSpace,
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor.withOpacity(0.12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              8.horizontalSpace,
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
