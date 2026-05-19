import 'dart:developer';

import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_router.dart';
import '../../app_config/app_colors.dart';
import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../dialog/exit_app_dialog.dart';
import '../svg_image/svg_image_widget.dart';
import 'cubit/bottom_navigation_cubit.dart';

class BottomNavBar extends StatefulWidget {
  final StatefulNavigationShell shell;
  const BottomNavBar({super.key, required this.shell});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late BottomNavigationCubit _bottomNavigationCubit;

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  int _selectedTab = 0;

  final List<List<int>> _tabBranchIndices = const [
    [0, 1, 2],
    [3, 4, 5, 6, 7],
    [8, 9, 10, 11, 12],
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavigationCubit = context.read<BottomNavigationCubit>();
  }

  void _onItemTapped(int index, [bool? reset]) {
    log("indexed id: $index");
    log("selectedTab id: $_selectedTab");

    if (reset ?? false) {
      if (_selectedTab != 0) {
        setState(() {
          _selectedTab = 0;
        });
      }
    }

    final branchIndex = _tabBranchIndices[_selectedTab][index];
    widget.shell.goBranch(branchIndex);
  }

  void _onTabSelect(int tab) {
    if (tab == _selectedTab) return;
    setState(() {
      _selectedTab = tab;
    });
    _onItemTapped(0);
  }

  @override
  Widget build(BuildContext context) {
    final baseHomePath =
        (widget.shell.route.branches[widget.shell.currentIndex].routes.first
                as GoRoute)
            .name;

    log("top: ${AppRouter.router.state.topRoute?.name == baseHomePath}");

    final currentBranchIndex = widget.shell.currentIndex;

    final tabIndexOfCurrent = _tabBranchIndices.indexWhere(
      (branches) => branches.contains(currentBranchIndex),
    );

    if (tabIndexOfCurrent != -1 && tabIndexOfCurrent != _selectedTab) {
      _selectedTab = tabIndexOfCurrent;
    }

    final homeBranchOfCurrentTab = tabIndexOfCurrent != -1
        ? _tabBranchIndices[tabIndexOfCurrent].first
        : 0;

    final show =
        currentBranchIndex == homeBranchOfCurrentTab &&
        AppRouter.router.state.topRoute?.name == baseHomePath;

    if (show) {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    } else {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    }

    final items = _getHomeItems[_selectedTab];

    final currentTabBranches = _tabBranchIndices[_selectedTab];
    int rawIndex = currentTabBranches.indexOf(currentBranchIndex);
    if (rawIndex == -1 || rawIndex >= items.length) {
      rawIndex = 0;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        log("result $didPop $result");

        if (didPop) return;

        final currentBranchIndex = widget.shell.currentIndex;
        final currentTabHomeBranch = _tabBranchIndices[_selectedTab].first;

        // If not on home branch of current tab, go to home of current tab
        if (currentBranchIndex != currentTabHomeBranch) {
          widget.shell.goBranch(currentTabHomeBranch);
        }
        // If already on home branch, show exit dialog
        else {
          final bool shouldPop = await showExitAppDialog(context);
          if (shouldPop) {
            SystemNavigator.pop();
          }
        }
      },
      child: BlocListener<BottomNavigationCubit, BottomNavigationState>(
        listener: (context, state) {
          if (state is ChangeBottomNavigationBranch) {
            _onTabSelect(0);
            _onItemTapped(state.index);
          }
        },
        child: Scaffold(
          extendBody: true,
          body: widget.shell,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: REdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
              child: Container(
                height: 68.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(items.length, (index) {
                    final isSelected = rawIndex == index;
                    final item = items[index];

                    if (isSelected) {
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              item.icon,
                              8.width,
                              Text(
                                item.label!,
                                style: TextStyle(
                                  color: AppColors.secondaryColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: SizedBox(
                          width: 44.w,
                          height: 48.h,
                          child: Center(child: item.icon),
                        ),
                      );
                    }
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToHomeScreen() {
    log("reset");
    _onItemTapped(0, true);
  }

  List<List<BottomNavigationBarItem>> get _getHomeItems => [
    _getViewerItems,
    _getEnterpriseItems,
    _getStudentItems,
  ];

  List<BottomNavigationBarItem> get _getViewerItems {
    return [
      navItem(
        title: AppStrings.home.tr(),
        icon: icon(AppIcons.home, 0),
        index: 0,
      ),
      navItem(
        title: AppStrings.explore.tr(),
        icon: icon(AppIcons.explore, 1),
        index: 1,
      ),
      navItem(
        title: AppStrings.setting.tr(),
        icon: icon(AppIcons.setting, 2),
        index: 2,
      ),
    ];
  }

  List<BottomNavigationBarItem> get _getStudentItems {
    return [
      navItem(
        title: AppStrings.home.tr(),
        icon: icon(AppIcons.home, 0),
        index: 0,
      ),
      navItem(
        title: AppStrings.work.tr(),
        icon: icon(AppIcons.work, 1),
        index: 1,
      ),
      navItem(
        title: AppStrings.community.tr(),
        icon: icon(AppIcons.community, 2),
        index: 2,
      ),
      navItem(
        title: AppStrings.bookmark.tr(),
        icon: icon(AppIcons.bookmark, 3),
        index: 3,
      ),
      navItem(
        title: AppStrings.setting.tr(),
        icon: icon(AppIcons.setting, 4),
        index: 4,
      ),
    ];
  }

  List<BottomNavigationBarItem> get _getEnterpriseItems {
    return [
      navItem(
        title: AppStrings.home.tr(),
        icon: icon(AppIcons.home, 0),
        index: 0,
      ),
      navItem(
        title: AppStrings.work.tr(),
        icon: icon(AppIcons.work, 1),
        index: 1,
      ),
      navItem(
        title: AppStrings.community.tr(),
        icon: icon(AppIcons.community, 2),
        index: 2,
      ),
      navItem(
        title: AppStrings.bookmark.tr(),
        icon: icon(AppIcons.bookmark, 3),
        index: 3,
      ),
      navItem(
        title: AppStrings.setting.tr(),
        icon: icon(AppIcons.setting, 4),
        index: 4,
      ),
    ];
  }

  Widget icon(String iconPath, int index) {
    final currentBranchIndex =
        _bottomNavigationCubit.navigationShell!.currentIndex;
    final tabBranches = _tabBranchIndices[_selectedTab];
    final currentIndexInTab = tabBranches.indexOf(currentBranchIndex);
    final isActive = currentIndexInTab == index;

    return SvgImageWidget(
      image: iconPath,
      colorFilter: isActive
          ? const ColorFilter.mode(AppColors.secondaryColor, BlendMode.srcIn)
          : const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 24.r,
      height: 24.r,
    );
  }

  BottomNavigationBarItem navItem({
    int index = 0,
    required String title,
    required Widget icon,
    int count = 0,
  }) {
    return BottomNavigationBarItem(icon: icon, label: title);
  }
}
