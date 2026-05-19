import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/di/service_locator.dart';
import 'package:flutter/services.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/features/shared/rewards/presentation/cubit/reward_history_cubit.dart';
import 'package:aflam/features/shared/rewards/presentation/widgets/history_shimmer.dart';
import 'package:aflam/features/shared/rewards/data/models/reward_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
    if (_isBottom) {
      context.read<RewardHistoryCubit>().loadMoreHistory();
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
      create: (context) => getIt<RewardHistoryCubit>()..getHistory(),
      child: Scaffold(
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: SafeArea(
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                20.height,

                /// Title
                Center(
                  child: Text(
                    AppStrings.promoCodes.tr(),
                    style: TextStyle(
                      color: AppColors.lightTText,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                20.height,

                Expanded(
                  child: BlocBuilder<RewardHistoryCubit, RewardHistoryState>(
                    builder: (context, state) {
                      if (state is RewardHistoryLoading) {
                        return const HistoryListShimmer();
                      }
                      if (state is RewardHistoryError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is RewardHistoryLoaded) {
                        if (state.history.isEmpty) {
                          return Center(child: Text(AppStrings.noHistory.tr()));
                        }
                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<RewardHistoryCubit>().getHistory(),
                          color: AppColors.secondaryColor,
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemCount:
                                state.history.length +
                                (state.hasReachedMax ? 0 : 1),
                            separatorBuilder: (_, __) => 8.height,
                            itemBuilder: (context, index) {
                              if (index >= state.history.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                );
                              }
                              final item = state.history[index];
                              return _AnimatedHistoryItem(
                                item: item,
                                index: index,
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedHistoryItem extends StatefulWidget {
  final RewardHistoryModel item;
  final int index;

  const _AnimatedHistoryItem({required this.item, required this.index});

  @override
  State<_AnimatedHistoryItem> createState() => _AnimatedHistoryItemState();
}

class _AnimatedHistoryItemState extends State<_AnimatedHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: _HistoryItem(item: widget.item),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final RewardHistoryModel item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    // Determine type/color based on points (positive = gain, negative = spend)
    final isGain = item.points >= 0;
    final color = isGain ? Colors.green : Colors.redAccent;
    final icon = isGain
        ? Icons.add_circle_outline
        : Icons.remove_circle_outline;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  image: (item.image != null && item.image!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(item.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (item.image == null || item.image!.isEmpty)
                    ? Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Icon(icon, color: color, size: 20.sp),
                      )
                    : null,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff1A1A1A),
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      item.formattedDate,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.nPoints.tr(
                      namedArgs: {'points': item.points.abs().toString()},
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    isGain ? "Earned" : "Spent", // Could be localized
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (item.content != null && item.content!.isNotEmpty) ...[
            12.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      item.content!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.code != null && item.code!.isNotEmpty) ...[
            12.verticalSpace,
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.code!));
                AppMessages.showSuccess(
                  context,
                  'Promo Code Copied to Clipboard!',
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondaryColor.withOpacity(0.1),
                      AppColors.secondaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.secondaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PROMO CODE",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          item.code!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: const Color(0xff1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 20.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
