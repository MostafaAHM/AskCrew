import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/widgets/workshop/workshop_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../viewer/home_viewer/presentation/widgets/home_top_bar.dart';
import 'artwok/artwork_tab.dart';
import '../../../../../core/helpers/authorization_helper.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';
import '../../../../../core/enums/jobs_filter.dart';
import '../../../../enter_prise/community_enterprise/presentation/screens/community_jobs_tab.dart';

class WorkEnterpriseBodyWidget extends StatefulWidget {
  final int initialTabIndex;
  const WorkEnterpriseBodyWidget({super.key, this.initialTabIndex = 0});

  @override
  State<WorkEnterpriseBodyWidget> createState() =>
      _WorkEnterpriseBodyWidgetState();
}

class _WorkEnterpriseBodyWidgetState extends State<WorkEnterpriseBodyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey<WorkshopTabState> _workshopTabKey =
      GlobalKey<WorkshopTabState>();
  final ValueNotifier<bool> _showFloatingButton = ValueNotifier<bool>(true);
  dynamic _selectedJob;
  bool _isAddingJob = false;
  bool _tabListenerAttached = false;

  Color get _orange => const Color(0xFFFF7A3C);
  Color get _lightPill => const Color(0xFFFFF0E3);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _showFloatingButton.value = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for route changes to reset WorkshopTab
    // This is a simplified check: if the widget is rebuilt and the route is different from what we expect, or if we navigated back.
    // However, with StatefulShellRoute, dependencies might not change often.
    // A better approach for "reset when leaving" using GoRouter listener.
    _setupRouteListener();
  }

  void _setupRouteListener() {
    final router = GoRouter.of(context);
    router.routerDelegate.addListener(_handleRouteChanged);
  }

  void _handleRouteChanged() {
    if (!mounted) return;

    // Check if we are still on the enterprise explore route
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();

    // If we navigated away from enterprise explore (and its sub-params), reset the tab.
    // Assuming Routes.enterpriseExplore is the base.
    if (!location.contains(Routes.enterpriseExplore)) {
      _workshopTabKey.currentState?.reset();
    }
  }

  @override
  void dispose() {
    // Remove listener is tricky because GoRouter might be disposed or context invalid.
    // Ideally we should keep a reference to routerDelegate.
    // But since this is a persistent widget in a ShellRoute, dispose is rarely called unless resizing/destroying app.
    // We can try:
    try {
      GoRouter.of(context).routerDelegate.removeListener(_handleRouteChanged);
    } catch (_) {}

    _animationController.dispose();
    _showFloatingButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    final isStudent = currentUser?.type.toLowerCase() == 'student';
    final isProducer = AuthorizationHelper.isProducer();
    final isEnterprise = currentUser?.type.toLowerCase() == 'enterprise';

    // Determine number of tabs
    // Student: Jobs + Workshop (2 tabs)
    // Enterprise Producer: Artwork + Workshop (2 tabs)
    // Enterprise Non-Producer: Workshop only (1 tab)
    final tabCount = isStudent ? 2 : (isProducer ? 2 : 1);

    return DefaultTabController(
      length: tabCount,
      initialIndex: widget.initialTabIndex,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          // Add listener for students to reset selectedJob when returning to Jobs tab
          if (isStudent && !_tabListenerAttached) {
            _tabListenerAttached = true;
            tabController.addListener(() {
              if (tabController.index == 0 && _selectedJob != null) {
                setState(() {
                  _selectedJob = null;
                });
              }
            });
          }

          return Stack(
            children: [
              Container(
                child: Padding(
                  padding: REdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.height,
                      AnimatedSlideIn(
                        index: 0,
                        controller: _animationController,
                        child: const HomeTopBar(showChat: true),
                      ),
                      10.height,
                      AnimatedSlideIn(
                        index: 1,
                        controller: _animationController,
                        child: _buildTopTabs(
                          isStudent: isStudent,
                          isProducer: isProducer,
                          isEnterprise: isEnterprise,
                        ),
                      ),
                      10.height,
                      Expanded(
                        child: AnimatedSlideIn(
                          index: 2,
                          controller: _animationController,
                          child: TabBarView(
                            children: _buildTabViews(
                              isStudent: isStudent,
                              isProducer: isProducer,
                              isEnterprise: isEnterprise,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isStudent) _buildFloatingButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopTabs({
    required bool isStudent,
    required bool isProducer,
    required bool isEnterprise,
  }) {
    // Build tabs list based on user type
    List<Widget> tabs = [];

    if (isStudent) {
      // Student: Jobs + Workshop
      tabs = [Tab(text: 'Jobs'.tr()), Tab(text: 'Workshop'.tr())];
    } else if (isEnterprise && isProducer) {
      // Enterprise Producer: Artwork + Workshop
      tabs = [Tab(text: 'Artwork'.tr()), Tab(text: 'Workshop'.tr())];
    } else {
      // Enterprise Non-Producer or Fallback: Workshop only
      tabs = [Tab(text: 'Workshop'.tr())];
    }

    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: _lightPill,
        borderRadius: BorderRadius.circular(40.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: TabBar(
        indicator: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(40.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs,
        onTap: (index) {
          if (isEnterprise && isProducer) {
            // Enterprise Producer: index 0 = Artwork, index 1 = Workshop
            if (index == 0) {
              _showFloatingButton.value = true;
            } else if (index == 1) {
              final workshopTabState = _workshopTabKey.currentState;
              if (workshopTabState != null &&
                  !workshopTabState.showAddWorkshop) {
                _showFloatingButton.value = true;
              }
            }
          } else if (isStudent) {
            // Student: index 0 = Jobs, index 1 = Workshop
            if (index == 1) {
              final workshopTabState = _workshopTabKey.currentState;
              if (workshopTabState != null &&
                  !workshopTabState.showAddWorkshop) {
                _showFloatingButton.value = true;
              }
            }
          } else {
            // Enterprise Non-Producer: only Workshop (index 0)
            final workshopTabState = _workshopTabKey.currentState;
            if (workshopTabState != null && !workshopTabState.showAddWorkshop) {
              _showFloatingButton.value = true;
            }
          }
        },
      ),
    );
  }

  List<Widget> _buildTabViews({
    required bool isStudent,
    required bool isProducer,
    required bool isEnterprise,
  }) {
    List<Widget> views = [];

    if (isStudent) {
      // Student: Jobs + Workshop
      views = [
        _buildJobsTab(),
        WorkshopTab(
          key: _workshopTabKey,
          onShowFloatingButtonChanged: (show) {
            _showFloatingButton.value = show;
          },
        ),
      ];
    } else if (isEnterprise && isProducer) {
      // Enterprise Producer: Artwork + Workshop
      views = [
        ArtworkTab(orange: _orange),
        WorkshopTab(
          key: _workshopTabKey,
          onShowFloatingButtonChanged: (show) {
            _showFloatingButton.value = show;
          },
        ),
      ];
    } else {
      // Enterprise Non-Producer or Fallback: Workshop only
      views = [
        WorkshopTab(
          key: _workshopTabKey,
          onShowFloatingButtonChanged: (show) {
            _showFloatingButton.value = show;
          },
        ),
      ];
    }

    return views;
  }

  Widget _buildJobsTab() {
    return CommunityJobsTab(
      orange: _orange,
      lightPill: _lightPill,
      isAddingJob: _isAddingJob,
      isStudent: true,
      selectedFilter: JobsFilter.suggested,
      selectedJob: _selectedJob,
      jobToEdit: null,
      onJobSelected: (job) {
        setState(() {
          _selectedJob = job;
        });
      },
      onFilterChanged: (value) {
        // Students only see suggested jobs
      },
      onJobCreated: () {
        setState(() {
          _isAddingJob = false;
        });
      },
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserHelper.userNotifier,
      builder: (context, user, _) {
        final isProducer = AuthorizationHelper.isProducer();
        final isEnterprise = user?.type.toLowerCase() == 'enterprise';

        // Only show for Enterprise users
        if (!isEnterprise) return const SizedBox.shrink();

        return Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _showFloatingButton,
                  builder: (context, showButton, _) {
                    final currentIndex = tabController.index;

                    // For Producer: show on Artwork (index 0) or Workshop (index 1)
                    // For Non-Producer: show only on Workshop (index 0)
                    final shouldShow = isProducer
                        ? (currentIndex == 0 ||
                              (currentIndex == 1 && showButton))
                        : (currentIndex == 0 && showButton);

                    if (!shouldShow) return const SizedBox.shrink();

                    final buttonText = (isProducer && currentIndex == 0)
                        ? 'Add Artwork'.tr()
                        : 'Add Workshop'.tr();

                    final borderRadius = BorderRadius.only(
                      bottomLeft: Radius.circular(25.r),
                      topRight: Radius.circular(25.r),
                    );

                    return Positioned(
                      right: 12.w,
                      bottom: 130.h,
                      child: AnimatedSlideIn(
                        index: 3,
                        controller: _animationController,
                        child: Material(
                          color: _orange,
                          elevation: 5,
                          borderRadius: borderRadius,
                          child: InkWell(
                            borderRadius: borderRadius,
                            onTap: () {
                              if (isProducer && currentIndex == 0) {
                                context.push(Routes.selectArtworkType);
                              } else {
                                _workshopTabKey.currentState?.openAddWorkshop();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 12.h,
                              ),
                              child: Text(
                                buttonText,
                                style: FontStyles.headline16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
