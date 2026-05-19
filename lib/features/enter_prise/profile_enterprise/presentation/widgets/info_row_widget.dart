import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF333333);
    const secondaryText = Color(0xFF888888);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 26.sp, color: secondaryText), // +4
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: primaryText,
                fontSize: 17.sp, // +4
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
