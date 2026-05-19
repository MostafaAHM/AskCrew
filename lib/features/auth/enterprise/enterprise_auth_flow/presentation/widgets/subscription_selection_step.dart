import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/enums/subscription_duration.dart';
import '../../../../../shared/plans/data/model/get_plans_response_model.dart';

class SubscriptionSelectionStep extends StatefulWidget {
  final List<SubscriptionPlanModel> plans;
  final PlanDiscountsModel discounts;
  final int? selectedPlanId;
  final SubscriptionDuration selectedDuration;
  final void Function(SubscriptionDuration duration) onDurationChanged;
  final void Function(int planId) onPlanSelected;
  final void Function()? onSkip;
  final bool isLoading;

  const SubscriptionSelectionStep({
    super.key,
    required this.plans,
    required this.discounts,
    required this.selectedPlanId,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onPlanSelected,
    this.onSkip,
    this.isLoading = false,
  });

  @override
  State<SubscriptionSelectionStep> createState() =>
      _SubscriptionSelectionStepState();
}

class _SubscriptionSelectionStepState extends State<SubscriptionSelectionStep>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      opacity: _isVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        offset: _isVisible ? Offset.zero : const Offset(0, 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.chooseYourSubscription.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  if (widget.onSkip != null)
                    GestureDetector(
                      onTap: widget.onSkip,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          AppStrings.skip.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              8.height,
              Text(
                AppStrings.pickThePlanDescription.tr(),
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              ),
              32.height,
              Row(
                children: [
                  Expanded(
                    child: _buildDurationButton(
                      duration: SubscriptionDuration.monthly,
                      isSelected:
                          widget.selectedDuration ==
                          SubscriptionDuration.monthly,
                      onTap: () => widget.onDurationChanged(
                        SubscriptionDuration.monthly,
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: _buildDurationButton(
                      duration: SubscriptionDuration.biannual,
                      isSelected:
                          widget.selectedDuration ==
                          SubscriptionDuration.biannual,
                      onTap: () => widget.onDurationChanged(
                        SubscriptionDuration.biannual,
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: _buildDurationButton(
                      duration: SubscriptionDuration.yearly,
                      isSelected:
                          widget.selectedDuration ==
                          SubscriptionDuration.yearly,
                      onTap: () =>
                          widget.onDurationChanged(SubscriptionDuration.yearly),
                    ),
                  ),
                ],
              ),
              32.height,
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: widget.isLoading
                    ? _buildShimmerPlans()
                    : Column(
                        children: [
                          for (int i = 0; i < widget.plans.length; i++) ...[
                            _buildAnimatedPlanCard(widget.plans[i], i),
                            if (i != widget.plans.length - 1)
                              Divider(
                                color: AppColors.borderColor,
                                thickness: 1,
                                height: 32.h,
                              ),
                          ],
                        ],
                      ),
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationButton({
    required SubscriptionDuration duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double discountVal = duration == SubscriptionDuration.biannual
        ? widget.discounts.threeMonthsDiscount
        : duration == SubscriptionDuration.yearly
        ? widget.discounts.yearlyDiscount
        : 0.0;
    final hasDiscount = discountVal > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryColor
                : AppColors.primaryColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  duration == SubscriptionDuration.monthly
                      ? AppStrings.monthly.tr()
                      : duration == SubscriptionDuration.biannual
                      ? AppStrings.biannual.tr()
                      : AppStrings.yearly.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.lightTText,
                  ),
                ),
              ),
            ),
            if (hasDiscount) ...[
              4.width,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${discountVal.toInt()}% ${AppStrings.percentOff.tr()}',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPlanCard(SubscriptionPlanModel plan, int index) {
    final isSelected = widget.selectedPlanId == plan.id;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 20, end: 0),
      duration: Duration(milliseconds: 220 + index * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(opacity: 1 - (value / 20).clamp(0, 1), child: child),
        );
      },
      child: _buildPlanCard(
        plan: plan,
        isSelected: isSelected,
        selectedDuration: widget.selectedDuration,
        onTap: () => widget.onPlanSelected(plan.id),
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlanModel plan,
    required bool isSelected,
    required SubscriptionDuration selectedDuration,
    required VoidCallback onTap,
  }) {
    final basePrice = double.tryParse(plan.price) ?? 0;
    double finalPrice = basePrice;

    if (selectedDuration == SubscriptionDuration.biannual) {
      final originalPrice = basePrice * 6;
      finalPrice =
          originalPrice -
          (originalPrice * (widget.discounts.threeMonthsDiscount / 100));
    } else if (selectedDuration == SubscriptionDuration.yearly) {
      final originalPrice = basePrice * 12;
      finalPrice =
          originalPrice -
          (originalPrice * (widget.discounts.yearlyDiscount / 100));
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryColor : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.secondaryColor
                        : AppColors.lightTText,
                  ),
                ),
                Text(
                  '${plan.currency} ${finalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
            16.height,
            ...plan.features.map((feature) {
              final limitText = feature.limit != null
                  ? ' (${feature.limit})'
                  : '';
              final text = '${feature.featureKeyDisplay}$limitText';

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18.sp,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.green,
                    ),
                    12.width,
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.lightMainText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlans() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Shimmer(
            child: Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColors.lightBGColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  12.height,
                  Container(
                    width: 80.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  16.height,
                  Container(
                    width: double.infinity,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  8.height,
                  Container(
                    width: double.infinity,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  8.height,
                  Container(
                    width: 160.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (i != 2)
            Divider(color: AppColors.borderColor, thickness: 1, height: 24.h),
        ],
      ],
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width;
            final gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            );
            return gradient.createShader(
              Rect.fromLTWH(0, 0, width, bounds.height),
            );
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
