import 'package:aflam/core/app_config/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutCard extends StatelessWidget {
  final String? aboutText;
  final String? cvPath;
  final String? cvName;
  final VoidCallback? onCvDownload;

  const AboutCard({
    super.key,
    this.aboutText,
    this.cvPath,
    this.cvName,
    this.onCvDownload,
  });

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF333333);
    const secondaryText = Color(0xFF636363);
    final cardColor = const Color(0xFFFE5B00).withOpacity(0.03);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'common_about'.tr(),
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 19.sp, // +4
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          if (aboutText != null && aboutText!.trim().isNotEmpty)
            Text(
              aboutText!,
              style: TextStyle(
                color: secondaryText,
                fontSize: 17.sp,
                height: 1.4,
              ),
            )
          else
            Text(
              'No bio yet',
              style: TextStyle(
                color: secondaryText.withOpacity(0.6),
                fontSize: 17.sp,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          if (cvPath != null && cvPath!.isNotEmpty && cvName != null && cvName!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                    size: 24.sp, // +4
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      cvName ?? '',
                      style: TextStyle(
                        fontSize: 17.sp, // +4
                        color: primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCvDownload,
                    child: Icon(
                      Icons.cloud_download_rounded,
                      size: 24.sp, // +4
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

