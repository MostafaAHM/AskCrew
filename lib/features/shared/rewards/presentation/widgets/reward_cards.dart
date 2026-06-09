import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/features/shared/rewards/data/models/reward_history_model.dart';
import 'package:aflam/features/shared/rewards/data/models/reward_model.dart';

class ActivityCard extends StatefulWidget {
  final RewardHistoryModel activity;
  final int index;

  const ActivityCard({super.key, required this.activity, this.index = 0});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
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
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF2EA),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  widget.activity.points >= 0
                      ? Icons.add_circle_outline_rounded
                      : Icons.remove_circle_outline_rounded,
                  color: const Color(0xffFE5B00),
                  size: 28.sp,
                ),
              ),
              (18).width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff1A1A1A),
                        fontFamily: 'Tajawal',
                        height: 1.3,
                      ),
                    ),
                    (6).height,
                    Text(
                      widget.activity.formattedDate,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xffBDBDBD),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.activity.points >= 0 ? '+' : ''}${widget.activity.points}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.activity.points >= 0
                          ? const Color(0xffFE5B00)
                          : Colors.redAccent,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardStoreCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onClaim;
  final bool isLoading;

  const RewardStoreCard({
    super.key,
    required this.reward,
    required this.onClaim,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xffFF8C42).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffFFF1E6).withOpacity(0.6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Center(
                  child: reward.imageUrl != null
                      ? CustomCachedNetworkImage(url: reward.imageUrl!)
                      : Icon(
                          Icons.card_giftcard_rounded,
                          size: 80.sp,
                          color: const Color(0xffFF8C42),
                        ),
                ),
              ),
              if (reward.discountTag != null)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFF8C42),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      reward.discountTag!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                (4).height,
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xff666666),
                  ),
                ),
                (16).height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${reward.points} ${AppStrings.points.tr()}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffFF8C42),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (reward.canClaim && !isLoading)
                          ? onClaim
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6B00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangle_borderRadius(12.r),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 10.h,
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const AnimatedLoading(color: Colors.white),
                            )
                          : Text(
                              AppStrings.rewardsClaim.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed minor syntax error in ElevatedButton return (RoundedRectangleBorder)
RoundedRectangleBorder RoundedRectangle_borderRadius(double r) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
