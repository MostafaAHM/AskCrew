import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';
import '../buttons/custom_button.dart';
import 'package:aflam/core/extensions/space_extension.dart';

Future<bool> showExitAppDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.primaryColor,
                    size: 32.sp,
                  ),
                ),
                24.height,

                // Title
                Text(
                  AppStrings.exitTheApp.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightMainText,
                    fontFamily:
                        'Cairo', // Assuming regular app font, or default
                  ),
                  textAlign: TextAlign.center,
                ),
                12.height,

                // Content
                Text(
                  AppStrings.exitConfirmMessage.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightSecMainText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                32.height,

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.outlined(
                        text: AppStrings.noThankYou.tr(),
                        borderColor: AppColors.primaryColor,
                        textColor: AppColors.primaryColor,
                        fontSize: 16.sp,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        radius: Radius.circular(12.r),
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.yesPlease.tr(),
                        isBackgroundGradient: true,
                        fontSize: 16.sp,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        radius: Radius.circular(12.r),
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}
