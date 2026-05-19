import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SegmentButton extends StatelessWidget {
  final String text;
  final bool selected;
  final Color orange;
  final VoidCallback onTap;

  const SegmentButton({
    super.key,
    required this.text,
    required this.selected,
    required this.orange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? orange : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: orange, width: 1.4),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : orange,
            ),
          ),
        ),
      ),
    );
  }
}
