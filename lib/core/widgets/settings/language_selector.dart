import 'package:aflam/core/app_config/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';
import '../../extensions/space_extension.dart';

class LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.changeLanguage.tr(),
          style: FontStyles.headline16.copyWith(
            color: AppColors.lightTText,
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        24.height,
        _LanguageOption(
          locale: const Locale('ar'),
          label: AppStrings.arabic.tr(),
          isSelected: currentLocale.languageCode == 'ar',
          onTap: () => onLanguageChanged(const Locale('ar')),
        ),
        12.height,
        _LanguageOption(
          locale: const Locale('en'),
          label: AppStrings.english.tr(),
          isSelected: currentLocale.languageCode == 'en',
          onTap: () => onLanguageChanged(const Locale('en')),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 20.sp,
            color: isSelected
                ? AppColors.secondaryColor
                : AppColors.borderColor,
          ),
          12.horizontalSpace,
          Expanded(
            child: Text(
              label,
              style: FontStyles.textStyle14.copyWith(
                color: AppColors.lightTText,
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20.sp,
            color: AppColors.lightTText,
          ),
        ],
      ),
    );
  }
}
