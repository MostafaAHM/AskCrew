import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_icons.dart';
import '../../app_config/font_styles.dart';

class PerformanceMetricCard extends StatelessWidget {
  final String type;
  final String label;
  final String value;
  final String? topWorkTitle;

  const PerformanceMetricCard({
    super.key,
    required this.type,
    required this.label,
    required this.value,
    this.topWorkTitle,
  });

  String get _iconPath {
    switch (type) {
      case 'views':
        return AppIcons.views;
      case 'bookings':
        return AppIcons.bookings;
      case 'topWork':
        return AppIcons.topWork;
      default:
        return AppIcons.topWork;
    }
  }

  bool get _isTopWork => type == 'topWork';

  String _displayValue() {
    final v = value.trim().replaceAll('..', '.');

    if (type == 'views') {
      final numStr = v.replaceAll(',', '');
      final parsed = double.tryParse(numStr);
      if (parsed != null) return parsed.toInt().toString();
      return v.split('.').first;
    }

    return v;
  }

  @override
  Widget build(BuildContext context) {
    if (_isTopWork) {
      // Top Work card with specific styling
      return Container(
        height: 96.h,
        padding: EdgeInsets.only(
          top: 15.h,
          right: 10.w,
          bottom: 15.h,
          left: 10.w,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFEFE),
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            bottom: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          ),
        ),
        child: _buildTopWorkCard(),
      );
    }

    // Standard cards (Views, Bookings)
    return Container(
      height: 75.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(10.r),
        border: Border(
          top: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          right: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          bottom: BorderSide.none,
          left: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
        ),
      ),
      child: _buildStandardCard(),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF1E8),
        border: Border.all(
          color: const Color(0xFFD1D1D1).withOpacity(0.35),
          width: 1.w,
        ),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        _iconPath,
        width: 22.sp,
        height: 22.sp,
        fit: BoxFit.contain,
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
    fontSize: 14.sp,
    color: AppColors.lightTText,
    fontWeight: FontWeight.w700,
    fontFamily: FontStyles.fontFamily,
  );

  TextStyle get _valueStyle => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    fontFamily: FontStyles.fontFamily,
    color: AppColors.secondaryColor,
  );

  Widget _buildStandardCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(),
        5.width,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.height,
              Flexible(
                child: Text(
                  _displayValue(),
                  style: _valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopWorkCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(),
        10.width,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: _labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    6.height,
                    Text(
                      _displayValue(),
                      style: _valueStyle.copyWith(fontSize: 22.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              10.width,
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    topWorkTitle ?? '',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                      fontFamily: FontStyles.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
