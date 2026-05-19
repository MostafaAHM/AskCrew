import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/user_stats_model.dart';

class ProfileStatsCard extends StatelessWidget {
  final UserStatsModel stats;

  const ProfileStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shop,
                  iconColor: const Color(0xFFFF5722),
                  iconBgColor: const Color(0xFFFF5722).withOpacity(0.1),
                  label: 'completedWorkshops',
                  value: stats.totalCompletedWorkshops.toString(),
                ),
              ),
              Container(
                height: 40.h,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star_outline,
                  iconColor: const Color(0xFFFF9800),
                  iconBgColor: const Color(0xFFFF9800).withOpacity(0.1),
                  label: 'ratings',
                  value: stats.meanRating.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFFFF5722),
                  iconBgColor: const Color(0xFFFF5722).withOpacity(0.1),
                  label: 'rentalProducts',
                  value: stats.totalRentedProducts.toString(),
                ),
              ),
              SizedBox(width: 8.w), // Space between cards
              Expanded(
                child: _buildStatItem(
                  icon: Icons.chat_bubble_outline,
                  iconColor: const Color(
                    0xFFFF5722,
                  ), // Using a warm color for consistency
                  iconBgColor: const Color(0xFFFF5722).withOpacity(0.1),
                  label: 'chats',
                  value: stats.totalChatRooms.toString(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.storefront_outlined,
                  iconColor: const Color(0xFFFF5722),
                  iconBgColor: const Color(0xFFFF5722).withOpacity(0.1),
                  label: 'myProducts',
                  value: stats.totalProductsForRent.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr(),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileStatsWidget extends StatelessWidget {
  final UserStatsModel stats;

  const ProfileStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Card (Workshops & Ratings)
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r), // Rounded
            border: Border.all(
              color: Colors.deepOrange,
              width: 1,
            ), // Orange border as in screenshot
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTopStatItem(
                  icon: Icons.inventory_2, // Looks like a box/inventory
                  iconColor: Colors.deepOrange,
                  iconBgColor: Colors.deepOrange.withOpacity(0.1),
                  label: 'completedWorkshops',
                  value: stats.totalCompletedWorkshops.toString(),
                ),
              ),
              Container(
                height: 40.h,
                width: 1,
                color: Colors
                    .deepPurple, // Divider color in screenshot looks purplish
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16.w),
                  child: _buildTopStatItem(
                    icon: Icons.star_outline,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.deepOrange.withOpacity(0.1),
                    label: 'ratings',
                    value: stats.meanRating.toStringAsFixed(1),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Bottom Row (3 Cards)
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                label: 'rentalProducts',
                icon: Icons.shopping_bag_outlined,
                value: stats.totalRentedProducts.toString(),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildSmallCard(
                label: 'chats',
                icon: Icons.chat_bubble_outline,
                value: stats.totalChatRooms.toString(),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildSmallCard(
                label: 'myProducts',
                icon: Icons.storefront_outlined,
                value: stats.totalProductsForRent.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr(),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w), // Smaller padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr(),
            style: TextStyle(
              fontSize: 11.sp, // Smaller font
              color: Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.deepOrange, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
