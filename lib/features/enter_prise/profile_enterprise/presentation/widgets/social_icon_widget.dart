import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_icons.dart';

enum SocialMediaType {
  facebook,
  instagram,
  linkedin,
  gmail,
  youtube,
}

class SocialIconWidget extends StatelessWidget {
  final SocialMediaType type;
  final VoidCallback? onTap;

  const SocialIconWidget({
    super.key,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.h,
        width: 32.w,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: _getIcon(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SocialMediaType.facebook:
        return const Color(0xFF1877F2); // Facebook blue
      case SocialMediaType.instagram:
        return const Color(0xFFE4405F); // Instagram gradient (using main color)
      case SocialMediaType.linkedin:
        return const Color(0xFF0077B5); // LinkedIn blue
      case SocialMediaType.gmail:
        return Colors.white;
      case SocialMediaType.youtube:
        return const Color(0xFFFF0000); // YouTube red
    }
  }

  Widget _getIcon() {
 

    switch (type) {
      case SocialMediaType.facebook:
        return SvgImageWidget(image: AppIcons.facebook, width: 24.w, height: 24.h);
      case SocialMediaType.instagram:
        return SvgImageWidget(image: AppIcons.instagram, width: 24.w, height: 24.h);
      case SocialMediaType.linkedin:
        return SvgImageWidget(image: AppIcons.linkedin, width: 24.w, height: 24.h);
      case SocialMediaType.gmail:
        return SvgImageWidget(image: AppIcons.email, width: 24.w, height: 24.h);
      case SocialMediaType.youtube:
        return SvgImageWidget(image: AppIcons.youtube, width: 24.w, height: 24.h);
    }
  }
}

