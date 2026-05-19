import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RewardsTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const RewardsTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xffFAF3ED);
    const activeColor = Color(0xffFE5B00);
    const textColor = Color(0xff1A1A1A);

    return SizedBox(
      height: 68.h,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, c) {
          final pillWidth = (c.maxWidth - 16.w) / 2;
          return Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  start: selectedIndex == 0 ? 0 : pillWidth,
                  top: 0,
                  bottom: 0,
                  width: pillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(35.r),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.35),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _TabItem(
                        isSelected: selectedIndex == 0,
                        icon: Icons.star_rounded,
                        label: AppStrings.rewardsGetActive.tr(),
                        onTap: () => onTabChanged(0),
                        activeColor: Colors.white,
                        inactiveColor: textColor,
                      ),
                    ),
                    Expanded(
                      child: _TabItem(
                        isSelected: selectedIndex == 1,
                        icon: Icons.shopping_bag_outlined,
                        label: AppStrings.rewardsStoreTab.tr(),
                        onTap: () => onTabChanged(1),
                        activeColor: Colors.white,
                        inactiveColor: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _TabItem({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? activeColor : inactiveColor,
            ),
            10.width,
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? activeColor : inactiveColor,
                fontFamily: 'Tajawal',
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
