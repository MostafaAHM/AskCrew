import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Rating section widget - displayed after payment
/// Shows "Send Feedback" heading, interactive star rating, and small rate button
class RatingSectionWidget extends StatefulWidget {
  final Function(int) onRateTap;

  const RatingSectionWidget({super.key, required this.onRateTap});

  @override
  State<RatingSectionWidget> createState() => _RatingSectionWidgetState();
}

class _RatingSectionWidgetState extends State<RatingSectionWidget> {
  int? _selectedRating;

  void _onStarTap(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  void _onRateSubmit() {
    if (_selectedRating != null && _selectedRating! > 0) {
      widget.onRateTap(_selectedRating!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        25.height,
        Text(
          'Send Feedback'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.lightMainText,
            fontSize: 16.sp,
          ),
        ),
        12.height,

        // Interactive star rating
        Row(
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isSelected =
                _selectedRating != null && starNumber <= _selectedRating!;

            return GestureDetector(
              onTap: () => _onStarTap(starNumber),
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: isSelected ? Colors.orange : Colors.grey[400],
                  size: 28.sp,
                ),
              ),
            );
          }),
        ),

        // Small rate button - only shown when rating is selected
        if (_selectedRating != null && _selectedRating! > 0) ...[
          16.height,
          CustomButton.outlined(
            text: "Rate".tr(),
            onTap: _onRateSubmit,
            width: null, // Let it size to content
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            fontSize: 14.sp,
            height: 40.h,
            radius: Radius.circular(8.r),
          ),
        ],
      ],
    );
  }
}
