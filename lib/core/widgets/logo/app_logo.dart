import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_icons.dart';
import '../svg_image/svg_image_widget.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.isSvg, this.width, this.height});
  final bool isSvg;
  final double? width, height;

  factory AppLogo.svg({double? width, double? height}) =>
      AppLogo(isSvg: true, width: width, height: height);

  factory AppLogo.png({double? width, double? height}) =>
      AppLogo(isSvg: false, width: width, height: height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDark ? AppIcons.logoDark : AppIcons.logo;
    // Check if the logo is a GIF (to use Image.asset instead of SvgPicture)
    final isGif = logoPath.toLowerCase().endsWith('.gif');

    return (isSvg && !isGif)
        ? SvgImageWidget(
            image: logoPath,
            width: width ?? 111.w,
            height: height ?? 36.h,
          )
        : Image.asset(
            isDark ? AppIcons.logoDarkPNG : AppIcons.logoPNG,
            width: width ?? 111.w,
            height: height ?? 36.h,
            fit: BoxFit.contain,
          );
  }
}
