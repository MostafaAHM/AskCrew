import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/rewards_cubit.dart';
import '../cubit/rewards_state.dart';
import '../widgets/reward_cards.dart';
import '../widgets/rewards_balance_card.dart';
import '../widgets/rewards_tabs.dart';
import '../widgets/rewards_shimmer.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedTabIndex == 0 && _isBottom) {
      context.read<RewardsCubit>().loadMoreActivities();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RewardsCubit>()..loadRewardsData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: BlocListener<RewardsCubit, RewardsState>(
          listener: (context, state) {
            if (state is RewardsLoaded) {
              if (state.redeemSuccessMessage != null) {
                AppMessages.showSuccess(context, state.redeemSuccessMessage!);
              }
              if (state.redeemError != null) {
                AppMessages.showError(context, state.redeemError!);
              }
            }
          },
          child: BlocBuilder<RewardsCubit, RewardsState>(
            builder: (context, state) {
              if (state is RewardsLoading) {
                return const RewardsScreenShimmer();
              }
              if (state is RewardsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<RewardsCubit>().loadRewardsData(),
                        child: Text(AppStrings.retry.tr()),
                      ),
                    ],
                  ),
                );
              }
              if (state is RewardsLoaded) {
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<RewardsCubit>().loadRewardsData(),
                  color: const Color(0xffFE5B00),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RewardsBalanceCard(
                          totalPoints: state.totalPoints,
                          nextLevelPoints: state.nextLevelPoints,
                        ),
                        (32).height,
                        RewardsTabs(
                          selectedIndex: _selectedTabIndex,
                          onTabChanged: (index) {
                            setState(() => _selectedTabIndex = index);
                          },
                        ),
                        (32).height,
                        if (_selectedTabIndex == 0) ...[
                          Text(
                            AppStrings.rewardsActivityList.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1A1A1A),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          (24).height,
                          if (state.activities.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Text(AppStrings.noHistory.tr()),
                              ),
                            )
                          else
                            ...List.generate(
                              state.activities.length,
                              (index) => ActivityCard(
                                activity: state.activities[index],
                                index: index,
                              ),
                            ),
                          if (!state.hasReachedMax &&
                              state.activities.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xffFE5B00),
                                ),
                              ),
                            ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.rewardsStoreTitle.tr(),
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff1A1A1A),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xffFE5B00,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      AppStrings.rewardsAllCategories.tr(),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xffFE5B00),
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    6.width,
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0xffFE5B00),
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          20.height,
                          ...state.rewards.map(
                            (reward) => RewardStoreCard(
                              reward: reward,
                              onClaim: () {
                                context.read<RewardsCubit>().redeemReward(
                                  reward.id,
                                );
                              },
                              isLoading: state.redeemingRewardId == reward.id,
                            ),
                          ),
                        ],
                        40.height,
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
