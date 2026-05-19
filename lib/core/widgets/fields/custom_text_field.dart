import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final bool readOnly;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final Function(String)? onChanged;
  final double? borderRadius;
  final bool isPhone;
  final Function(String)? onPhoneChanged;
  final int height;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.readOnly = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.validator,
    this.onTap,
    this.minLines,
    this.maxLines,
    this.inputFormatters,
    this.textStyle,
    this.onChanged,
    this.labelStyle,
    this.borderRadius,
    this.enabled = true,
    this.isPhone = false,
    this.onPhoneChanged,
    this.height = 52,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (isPhone) {
      return CustomPhoneField(
        label: label,
        hint: hint,
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        textStyle: textStyle,
        labelStyle: labelStyle,
        onChanged: onPhoneChanged ?? onChanged,
        borderRadius: borderRadius,
        focusNode: focusNode,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w, bottom: 8.h),
            child: Text(
              label!,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTText,
                  ),
            ),
          ),
        ],
        TextFormField(
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines ?? (obscure ? 1 : null),
          inputFormatters: inputFormatters,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          style:
              textStyle ??
              TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTText,
              ),
          textAlignVertical: TextAlignVertical.center,
          decoration: _AppInputDecoration.build(
            hint: hint,
            prefix: prefix,
            suffix: suffix,
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }
}

class CustomPhoneField extends StatelessWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final Function(String)? onChanged;
  final double? borderRadius;
  final FocusNode? focusNode;

  const CustomPhoneField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.validator,
    this.textStyle,
    this.labelStyle,
    this.onChanged,
    this.borderRadius,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w, bottom: 8.h),
            child: Text(
              label!,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTText,
                  ),
            ),
          ),
        ],
        IntlPhoneField(
          focusNode: focusNode,
          controller: controller,
          initialCountryCode: 'KW',
          invalidNumberMessage: AppStrings.invalidPhoneNumber.tr(),
          dropdownIconPosition: IconPosition.trailing,
          flagsButtonPadding: EdgeInsets.only(left: 16.w),
          dropdownIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryColor,
            size: 20.sp,
          ),
          decoration: _AppInputDecoration.build(
            hint: hint,
            borderRadius: borderRadius,
          ),
          enabled: enabled,
          readOnly: readOnly,
          style:
              textStyle ??
              TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.lightTText,
              ),
          onTap: onTap,
          onChanged: (phone) {
            final value = phone.completeNumber;
            if (onChanged != null) {
              onChanged!(value);
            }
          },
          validator: (phone) {
            if (validator == null) return null;
            return validator!(phone?.completeNumber);
          },
        ),
      ],
    );
  }
}

class _AppInputDecoration {
  static InputDecoration build({
    String? hint,
    Widget? prefix,
    Widget? suffix,
    double? borderRadius,
  }) {
    final radius = BorderRadius.circular(borderRadius ?? 30.r);

    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFFAF9F6),
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 16.sp,
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.redColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.redColor, width: 1),
      ),
      errorStyle: TextStyle(
        fontSize: 11.sp,
        color: AppColors.redColor,
        height: 1.2,
      ),
    );
  }
}
