import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/movie_model.dart';
import '../cached_network_image/custom_cached_network_image.dart';

class MoviePosterOnly extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const MoviePosterOnly({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 105,
    this.height = 126,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: CustomCachedNetworkImage(
            url: movie.posterUrl,
            fit: BoxFit.cover,
            serverImage: true,
          ),
        ),
      ),
    );
  }
}
