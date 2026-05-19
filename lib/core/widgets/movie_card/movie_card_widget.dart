import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/models/movie_model.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';

class MovieCardWidget extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final double? posterWidth;
  final double? posterHeight;

  const MovieCardWidget({
    super.key,
    required this.movie,
    this.onTap,
    this.posterWidth,
    this.posterHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.lightBGColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CustomCachedNetworkImage(
                url: movie.posterUrl,
                width: posterWidth ?? 80.w,
                height: posterHeight ?? 120.h,
                fit: BoxFit.cover,
                serverImage: true,
              ),
            ),
            12.width,
            // Movie Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: FontStyles.textStyle18.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightMainText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height,
                  // Release Date
                  Text(
                    DateFormat('dd MMM yyyy').format(movie.releaseDate),
                    style: FontStyles.textStyle14.copyWith(
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height,
                  // Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: AppColors.yellowColor,
                      ),
                      4.width,
                      Flexible(
                        child: Text(
                          movie.rating.toStringAsFixed(1),
                          style: FontStyles.textStyle14.copyWith(
                            color: AppColors.lightMainText,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
