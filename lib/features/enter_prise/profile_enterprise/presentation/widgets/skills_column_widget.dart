import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsColumnWidget extends StatelessWidget {
  final List<String> skills;

  const SkillsColumnWidget({
    super.key,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    const bulletColor = Color(0xFFFF7A2F);
    const primaryText = Color(0xFF333333);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills
          .map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8.sp,
                    color: bulletColor,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 17.sp, // +4
                        color: primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

