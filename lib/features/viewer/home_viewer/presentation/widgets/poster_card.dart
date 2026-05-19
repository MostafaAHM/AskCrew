import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../data/model/movie.dart';

class PosterCard extends StatelessWidget {
  final Movie movie;

  const PosterCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        Routes.movieDetails,
        extra: {
          'movie': movie,
          'isPurchased': false,
        },
      ),
      child: SizedBox(
        width: 110.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CustomCachedNetworkImage(
                height: 150.h,
                width: 110.w,
                fit: BoxFit.cover,
                url: movie.imageUrl,
              ),
            ),
            8.height,
            Row(
              children: [
                Expanded(
                  child: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                6.width,
                Icon(Icons.star, color: Colors.orange, size: 16.sp),
                4.width,
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
