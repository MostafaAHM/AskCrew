import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';

class StudentWorkshopCard extends StatelessWidget {
  final String title;
  final String date;
  final String instructor;
  final String imageUrl;
  final VoidCallback onTap;

  const StudentWorkshopCard({
    super.key,
    required this.title,
    required this.date,
    required this.instructor,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 174.w,
        height: 154.h,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
              child: Container(
                height: 100.h,
                width: double.infinity,
                color: AppColors.lightBGColor,
                child: imageUrl.isNotEmpty
                    ? CustomCachedNetworkImage(
                        url: imageUrl,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.image,
                        size: 50,
                        color: AppColors.greyText,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTText,
                        fontFamily: 'Tajawal',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.greyText,
                        fontFamily: 'Tajawal',
                        height: 1.2,
                      ),
                    ),
                    2.height,
                    Text(
                      instructor,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.greyText,
                        fontFamily: 'Tajawal',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

