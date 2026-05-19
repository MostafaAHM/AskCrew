import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(int? index)? onTap;
  final List<String> tabTitles;
  final TabController? controller;
  const CustomTabBar({
    super.key,
    required this.onTap,
    required this.tabTitles,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      tabs: List.generate(
        tabTitles.length,
        (index) => Tab(
          // text: tabTitles[index],
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tabTitles[index],
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.primaryColor,
      indicatorWeight: 4,
      labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
      ),
      labelColor: Theme.of(context).textTheme.labelLarge?.color,
      unselectedLabelColor: Theme.of(context).textTheme.labelLarge?.color,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
