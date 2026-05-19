import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/features/viewer/favorites/presentation/widgets/favorite_button.dart';

import '../../data/model/movies_with_series_model.dart';

class MovieOrSeriesCard extends StatelessWidget {
  final MovieOrSeriesItem item;
  final VoidCallback onTap;
  final double? width;

  const MovieOrSeriesCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 110.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: CustomCachedNetworkImage(
                        fit: BoxFit.cover,
                        url: item.displayCoverImage ?? '',
                        serverImage: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: FavoriteButton(
                    contentType: item.contentType,
                    objectId: item.id,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    item.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (item.ratingMean != null) ...[
                  4.width,
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                  2.width,
                  Text(
                    item.ratingMean!.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
