import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_icons.dart';
import 'booking_filter_bottom_sheet.dart';

class FilteringWidget extends StatefulWidget {
  final Function(bool? mine, bool? suggested, List<String> types)
  onFilterChanged;
  final Function(bool isMine) onTabChanged;

  const FilteringWidget({
    super.key,
    required this.onFilterChanged,
    required this.onTabChanged,
  });

  @override
  State<FilteringWidget> createState() => _FilteringWidgetState();
}

class _FilteringWidgetState extends State<FilteringWidget> {
  bool _isMineSelected = true;
  final List<String> _selectedTypes = [];
  Color get _orange => const Color(0xFFFF7A3C);
  Color get _lightPill => const Color(0xFFFFF0E3);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tabs
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: _lightPill,
            borderRadius: BorderRadius.circular(40.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(AppStrings.myOwn.tr(), true),
              8.width,
              _buildTab(AppStrings.suggested.tr(), false),
            ],
          ),
        ),
        // Filter Icon
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
          child: SvgImageWidget(
            image: AppIcons.filter,
            width: 24.w,
            height: 24.h,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isMine) {
    final isSelected = _isMineSelected == isMine;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMineSelected = isMine;
        });
        widget.onTabChanged(isMine);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? _orange : Colors.transparent,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xff1A0A00),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (sheetContext) {
        return BookingFilterBottomSheet(
          selectedTypes: List.from(_selectedTypes),
          onFilterApplied: (selectedTypes) {
            setState(() {
              _selectedTypes.clear();
              _selectedTypes.addAll(selectedTypes);
            });
            widget.onFilterChanged(
              _isMineSelected ? true : null,
              !_isMineSelected ? true : null,
              selectedTypes,
            );
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }
}
