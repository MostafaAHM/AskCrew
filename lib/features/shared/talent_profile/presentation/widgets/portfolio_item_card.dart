import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/app_config/app_colors.dart';
import '../../data/models/talent_work_model.dart';
import 'package:shimmer/shimmer.dart';

class PortfolioItemCard extends StatelessWidget {
  final TalentWorkModel work;

  const PortfolioItemCard({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Column(
        children: [
          if (work.title.isNotEmpty) ...[
            Text(
              work.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.secondaryColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            8.verticalSpace,
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: work.posterUrl,
              height: 140.h,
              width: 100.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 140.h,
                  width: 100.w,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 140.h,
                width: 100.w,
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
          if (work.category.isNotEmpty) ...[
            8.verticalSpace,
            Text(
              work.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
