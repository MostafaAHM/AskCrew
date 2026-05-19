import 'package:aflam/core/app_config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/features/viewer/favorites/presentation/widgets/favorite_button.dart';

import '../../../../../core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../data/models/explore_response_model.dart';

class ExploreVideoCard extends StatefulWidget {
  final ExploreItemModel item;
  final int index;
  final VoidCallback? onTap;

  const ExploreVideoCard({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  @override
  State<ExploreVideoCard> createState() => _ExploreVideoCardState();
}

class _ExploreVideoCardState extends State<ExploreVideoCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: value * (_pressed ? 0.97 : 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomCachedNetworkImage(
                  fit: BoxFit.cover,
                  url: widget.item.coverImage ?? '',
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.30),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 24.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                right: 16.w,
                child: FavoriteButton(
                  contentType: widget.item.contentType,
                  objectId: widget.item.id,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
