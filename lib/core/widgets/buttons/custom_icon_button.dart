import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../svg_image/svg_image_widget.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.iconSize,
    this.bgSize,
    this.bgColor,
    this.bgRadius,
    this.isNetwork,
    this.onTap,
    this.padding,
    this.colorFilter,
  });
  final String icon;
  final double? iconSize, bgSize, bgRadius, padding;
  final Color? bgColor;
  final bool? isNetwork;
  final Function()? onTap;
  final ColorFilter? colorFilter;
  factory CustomIconButton.lightBlueBg({
    required Function()? onTap,
    required String icon,
    required bool isNetwork,
  }) => CustomIconButton(
    isNetwork: isNetwork,
    icon: icon,
    bgColor: AppColors.lightImageBgColor,
    onTap: onTap,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding ?? 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(bgRadius ?? 6.r),
        color: bgColor ?? AppColors.iconButtonBG,
      ),
      child: SvgImageWidget(
        isNetwork: isNetwork,
        image: icon,
        colorFilter: colorFilter,
        onTap: onTap,
        width: iconSize?.h,
        height: iconSize?.w,
      ),
    );
  }
}
