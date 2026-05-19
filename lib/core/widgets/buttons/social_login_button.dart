import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_config/app_icons.dart';

enum SocialType { google, facebook, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialType type;
  final VoidCallback? onTap;

  const SocialLoginButton({super.key, required this.type, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
        ),
        child: Center(child: _getIcon()),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SocialType.google:
        return Colors.white;
      case SocialType.facebook:
        return const Color(0xFF1877F2);
      case SocialType.apple:
        return Colors.black;
    }
  }

  Widget _getIcon() {
    switch (type) {
      case SocialType.google:
        return SvgPicture.asset(AppIcons.google, width: 24.w, height: 24.h);
      case SocialType.facebook:
        return SvgPicture.asset(
          AppIcons.facebook,
          width: 24.w,
          height: 24.h,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
      case SocialType.apple:
        return Icon(Icons.apple, color: Colors.white, size: 24.sp);
    }
  }
}
