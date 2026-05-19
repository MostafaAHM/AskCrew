import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingFilterBottomSheet extends StatefulWidget {
  final List<String> selectedTypes;
  final Function(List<String> selectedTypes) onFilterApplied;

  const BookingFilterBottomSheet({
    super.key,
    required this.selectedTypes,
    required this.onFilterApplied,
  });

  @override
  State<BookingFilterBottomSheet> createState() =>
      _BookingFilterBottomSheetState();
}

class _BookingFilterBottomSheetState extends State<BookingFilterBottomSheet> {
  late List<String> _selectedTypes;
  Color get _orange => const Color(0xFFFF7A3C);

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    final navBarHeight = 10.h;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalBottomSpace = navBarHeight + bottomPadding;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBGColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          12.height,
          // Title
          Center(
            child: Text(
              AppStrings.filterBookings.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1A0A00),
              ),
            ),
          ),
          16.height,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              AppStrings.selectYourCategory.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1A0A00),
              ),
            ),
          ),
          12.height,
          // Category Checkboxes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildCategoryCheckbox(AppStrings.tool.tr(), 'tool'),
                ),
                12.width,
                Expanded(
                  child: _buildCategoryCheckbox(
                    AppStrings.studio.tr(),
                    'studio',
                  ),
                ),
              ],
            ),
          ),
          20.height,
          // Buttons Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.reset.tr(),
                    isBackgroundGradient: false,
                    backgroundColor: Colors.grey.shade300,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1A0A00),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedTypes.clear();
                      });
                      widget.onFilterApplied([]);
                    },
                  ),
                ),
                12.width,
                Expanded(
                  child: CustomButton(
                    text: AppStrings.filter.tr(),
                    isBackgroundGradient: true,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_orange, AppColors.primaryColor],
                    ),
                    onTap: () {
                      widget.onFilterApplied(_selectedTypes);
                    },
                  ),
                ),
              ],
            ),
          ),
          16.height,
          SizedBox(height: totalBottomSpace),
        ],
      ),
    );
  }

  Widget _buildCategoryCheckbox(String label, String value) {
    final isSelected = _selectedTypes.contains(value);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTypes.remove(value);
          } else {
            _selectedTypes.add(value);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _orange : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? _orange : AppColors.borderColor,
                  width: 2,
                ),
                color: isSelected ? _orange : Colors.white,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
            12.width,
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xff1A0A00)
                      : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
