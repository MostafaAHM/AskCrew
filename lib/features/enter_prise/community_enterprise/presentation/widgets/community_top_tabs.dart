import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityTopTabs extends StatelessWidget {
  final Color orange;

  const CommunityTopTabs({super.key, required this.orange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE7D9),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: orange,
          borderRadius: BorderRadius.circular(20.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.brown[700],
        labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Questions'.tr()),
          Tab(text: 'Jobs'.tr()),
        ],
      ),
    );
  }
}
