import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../buttons/back_button.dart';
import '../buttons/skip_button.dart';
import '../logo/app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  const CustomAppBar({
    super.key,
    this.customTitle,
    this.leading,
    this.title,
    this.centerTitle,
    this.bottomWidget,
    this.isShown,
    this.backgroundColor,
    this.showLogoInBackAppBar,

    this.actions,
  });

  final Widget? customTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottomWidget;
  final String? title;
  final bool? showLogoInBackAppBar;

  final Color? backgroundColor;
  final bool? centerTitle, isShown;
  factory CustomAppBar.logoSkipAppBar({Function()? onTap}) => CustomAppBar(
    leading: SkipButton(onTap: onTap),
    customTitle: AppLogo.svg(width: 150.w, height: 50.h),
  );
  factory CustomAppBar.logoAppBar() =>
      CustomAppBar(leading: null, customTitle: AppLogo.svg(width: 150.w, height: 50.h));
  factory CustomAppBar.backAppBar({
    String? title,
    PreferredSizeWidget? bottomWidget,
    List<Widget>? actions,
    bool? centerTitle,
    Color? backgroundColor,
    VoidCallback? onBackPressed,
    bool showLogoInBackAppBar = false,
    Widget? leading,
  }) => CustomAppBar(
    actions: actions,
    backgroundColor: backgroundColor,
    centerTitle: centerTitle ?? showLogoInBackAppBar,
    leading: leading ?? CustomBackButton(onPressed: onBackPressed),
    customTitle: showLogoInBackAppBar
        ? AppLogo.png(height: 70.h, width: 100.w)
        : null,
    title: showLogoInBackAppBar ? null : title,
    bottomWidget: bottomWidget,
    showLogoInBackAppBar: showLogoInBackAppBar,
  );

  factory CustomAppBar.homeAppBar({
    VoidCallback? onLogoTap,
    bool? isShown,
    PreferredSizeWidget? bottomWidget,
  }) => CustomAppBar(
    centerTitle: true,
    isShown: isShown,
    bottomWidget: bottomWidget,
    customTitle: GestureDetector(onTap: onLogoTap, child: AppLogo.svg(width: 150.w, height: 50.h)),
  );
  @override
  Widget build(BuildContext context) {
    double height = bottomWidget != null
        ? kToolbarHeight + kTextTabBarHeight
        : kToolbarHeight;
    return AppBar(
      actions: actions,
      centerTitle: centerTitle ?? true,
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      leadingWidth: 60.w,
      leading: leading == null ? null : Center(child: leading),
      toolbarHeight: height,
      bottom: bottomWidget,
      title:
          customTitle ??
          (title != null
              ? Text(
                  title!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontSize: 18.sp),
                )
              : null),
    );
  }

  @override
  Widget get child => AnimatedSlide(
    duration: const Duration(milliseconds: 500),
    offset: Offset(0, isShown ?? false ? 0 : -kToolbarHeight),
    child: AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 60.w,
      leading: SkipButton(onTap: () {}),
      title: AppLogo.svg(),
    ),
  );

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
