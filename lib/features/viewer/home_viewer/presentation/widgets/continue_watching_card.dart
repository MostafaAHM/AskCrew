import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/app_config/app_colors.dart';
import '../../../../../core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../../continue_watching/data/models/continue_watching_item_model.dart';
import '../../data/model/movies_with_series_model.dart';

class ContinueWatchingCard extends StatelessWidget {
  final ContinueWatchingItemModel item;
  final VoidCallback? onTap;

  const ContinueWatchingCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final MovieOrSeriesItem? content = item.contentData;
    if (content == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FBFF),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Poster(
                imageUrl: content.displayCoverImage ?? '',
                progress: item.progress,
              ),
              SizedBox(height: 8.h),
              _TitleText(content.displayName),
              SizedBox(height: 4.h),
              _SubtitleRow(
                categoryName: content.category?.name ?? '',
                rating: content.ratingMean ?? 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String imageUrl;
  final int progress;

  const _Poster({required this.imageUrl, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 105.h,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomCachedNetworkImage(fit: BoxFit.cover, url: imageUrl),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FractionallySizedBox(
                widthFactor: (progress / 100.0).clamp(0.0, 1.0),
                child: Container(height: 4.h, color: const Color(0xFFFE5B00)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String title;

  const _TitleText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.sp,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: AppColors.lightTText,
      ),
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  final String categoryName;
  final double rating;

  const _SubtitleRow({required this.categoryName, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: AppColors.bodyText),
          ),
        ),
        SizedBox(width: 6.w),
        Icon(Icons.star_rounded, color: const Color(0xFFFE5B00), size: 14.sp),
        SizedBox(width: 3.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            color: const Color(0xFFFE5B00),
          ),
        ),
      ],
    );
  }
}
