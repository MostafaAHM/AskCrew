import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_config/app_colors.dart';
import '../widgets/animated_loading/animated_loading.dart';

class AppMessages {
  static bool _isLoading = false;
  static BuildContext? _loadingContext;

  static Future<dynamic> showLoading(BuildContext context) {
    if (_isLoading) return Future.value(null);
    _isLoading = true;
    _loadingContext = context;
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: AnimatedLoading()),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    if (!_isLoading) return;
    if (_loadingContext != null && _loadingContext!.mounted) {
      try {
        Navigator.of(_loadingContext!, rootNavigator: true).pop();
      } catch (e) {
        // Dialog might already be dismissed
      }
    }
    _isLoading = false;
    _loadingContext = null;
  }
  /*  static Future<dynamic> showConfirmDialog(
    BuildContext context, {
    required String title,
    Widget? content,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bebas Neue',
            ),
          ),
          content: content,
          actionsOverflowButtonSpacing: 8.w,
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.save.tr(),
                    isBackgroundGradient: true,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
                8.width,
                Expanded(
                  child: CustomButton(
                    text: AppStrings.cancel.tr(),
                    hasBorder: true,
                    backgroundColor: Colors.transparent,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      );*/

  static void showError(
    BuildContext context,
    String error, [
    SnackBarAction? action,
  ]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.errorColor.withOpacity(0.95),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20.r,
              ),
            ),
            12.horizontalSpace,
            Flexible(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, [
    SnackBarAction? action,
  ]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green.withOpacity(0.95),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20.r,
              ),
            ),
            12.horizontalSpace,
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }
}
