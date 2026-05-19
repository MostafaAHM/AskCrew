import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header section with cover image and play button
class ContentHeaderWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onPlayTap;

  const ContentHeaderWidget({
    super.key,
    required this.imageUrl,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomCachedNetworkImage(
            fit: BoxFit.cover,
            url: imageUrl,
            serverImage: true,
          ),
          Center(
            child: GestureDetector(
              onTap: onPlayTap,
              child: Container(
                height: 65.r,
                width: 65.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.9),
                ),
                child: Icon(Icons.play_arrow, size: 36.sp, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
