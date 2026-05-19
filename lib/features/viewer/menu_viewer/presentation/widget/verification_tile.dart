import 'package:aflam/core/app_config/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/app_config/app_colors.dart';
import '../../../../../../core/app_config/app_icons.dart';
import '../../../../../../core/widgets/svg_image/svg_image_widget.dart';

class VerificationTile extends StatelessWidget {
  final bool isVerified;
  final bool isLoading;
  final VoidCallback onTap;

  const VerificationTile({
    super.key,
    required this.isVerified,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (isVerified || isLoading) ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isVerified
                ? Border.all(color: Colors.blueAccent, width: 1)
                : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 24.sp,
                height: 24.sp,
                alignment: Alignment.center,
                child: isVerified
                    ? Icon(
                        Icons.verified,
                        color: Colors.blueAccent,
                        size: 24.sp,
                      )
                    : SvgImageWidget(
                        image: AppIcons.profile,
                        width: 24.sp,
                        height: 24.sp,
                        colorFilter: const ColorFilter.mode(
                          Color(0xff4b4b4b),
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Text(
                  isVerified
                      ? AppStrings.verifiedAccount.tr()
                      : AppStrings.verifyAccount.tr(),
                  style: TextStyle(
                    fontSize: 19.sp,
                    color: const Color(0xff4b4b4b),
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (!isVerified)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.payNow.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
