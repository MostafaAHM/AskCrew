import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';

class PhoneNumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(dynamic)? validator;
  final Function(String)? onChanged;
  final Function(dynamic)? onCountryChanged;

  const PhoneNumberField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 12.w, bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTText,
            ),
          ),
        ),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: 'KW',
          dropdownIconPosition: IconPosition.trailing,
          flagsButtonPadding: EdgeInsets.only(left: 16.w),
          showCountryFlag: true,
          dropdownIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryColor,
            size: 20.sp,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.hintColor,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(
                color: AppColors.secondaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.redColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(
                color: AppColors.redColor,
                width: 1.5,
              ),
            ),
            errorStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.redColor,
              height: 1,
            ),
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTText,
          ),
          onChanged: (phone) {
            try {
              final completeNumber = phone.completeNumber;
              if (completeNumber.isNotEmpty) {
                onChanged?.call(completeNumber);
              }
            } catch (_) {}
          },
          onCountryChanged: (country) {
            try {
              onCountryChanged?.call(country);
            } catch (_) {}
          },
          validator: (phone) {
            try {
              if (phone == null || phone.number.isEmpty) {
                return AppStrings.phoneNumberIsRequired.tr();
              }
              if (validator != null) {
                return validator!(phone);
              }
              return null;
            } catch (_) {
              return AppStrings.phoneNumberIsRequired.tr();
            }
          },
          disableLengthCheck: false,
          invalidNumberMessage: AppStrings.invalidPhoneNumber.tr(),
          keyboardType: TextInputType.phone,
          textAlignVertical: TextAlignVertical.center,
        ),
      ],
    );
  }
}
