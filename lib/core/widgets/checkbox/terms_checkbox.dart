import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';
import '../../extensions/space_extension.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String text;
  final String? linkText;
  final VoidCallback? onLinkTap;

  const TermsCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    required this.text,
    this.linkText,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.lightBGColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.lightMainText.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: Checkbox(
              value: value,
              onChanged: (newValue) => onChanged?.call(newValue ?? false),
              activeColor: AppColors.secondaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: AppColors.lightMainText.withOpacity(0.4),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          10.width,
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onChanged?.call(!value),
              child: RichText(
                text: TextSpan(
                  style: FontStyles.textStyle14.copyWith(
                    color: AppColors.lightMainText,
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: text),
                    if (linkText != null)
                      TextSpan(
                        text: linkText,
                        style: FontStyles.textStyle14.copyWith(
                          color: AppColors.lightMainText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: onLinkTap != null
                            ? (TapGestureRecognizer()..onTap = onLinkTap)
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
