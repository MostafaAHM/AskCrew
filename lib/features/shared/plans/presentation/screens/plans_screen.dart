import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/enums/subscription_duration.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/shared/payment/presentation/screens/payment_webview_screen.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/features/shared/plans/data/model/get_plans_response_model.dart';
import 'package:aflam/features/shared/plans/presentation/cubit/activate_plan_cubit.dart';
import 'package:aflam/features/shared/plans/presentation/cubit/activate_plan_state.dart';
import 'package:aflam/features/shared/plans/presentation/cubit/get_all_plan_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  SubscriptionDuration _selectedDuration = SubscriptionDuration.monthly;
  int? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<GetAllPlanCubit>()..getAllPlans(),
        ),
        BlocProvider(create: (context) => getIt<ActivatePlanCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppStrings.plans.tr(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<ActivatePlanCubit, ActivatePlanState>(
          listener: (context, state) {
            if (state is ActivatePlanSuccess) {
              final url = state.response.paymentUrl;
              if (url != null && url.isNotEmpty) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => PaymentWebViewScreen(
                      paymentUrl: url,
                      onPaymentSuccess: () {
                        context.read<ProfileCubit>().getMyProfile();
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.of(context).pop(); // pop plans screen
                      },
                      onPaymentCancel: () {
                        AppMessages.showError(context, 'paymentCancelled'.tr());
                      },
                    ),
                  ),
                );
              } else {
                // No payment URL, direct success (free plan or already included)
                context.read<ProfileCubit>().getMyProfile();
                AppMessages.showSuccess(
                  context,
                  'plan_activated_successfully'.tr(),
                );
                Navigator.pop(context);
              }
            } else if (state is ActivatePlanError) {
              AppMessages.showError(context, state.message);
            }
          },
          child: BlocBuilder<GetAllPlanCubit, GetAllPlanState>(
            builder: (context, state) {
              if (state is GetAllPlanLoading) {
                return const Center(child: AnimatedLoading());
              } else if (state is GetAllPlanSuccess) {
                return _buildContent(
                  context,
                  state.plansResponse.results,
                  state.discounts,
                );
              } else if (state is GetAllPlanFailure) {
                return Center(child: Text(state.errorMessage));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SubscriptionPlanModel> plans,
    PlanDiscountsModel discounts,
  ) {
    final userCubit = context.read<ProfileCubit>();
    final currentUser = userCubit.currentUser;
    final currentPlanId = currentUser?.profile?.plan?['id'];
    final userType = currentUser?.type ?? '';

    // Filter plans based on user type
    final filteredPlans = plans.where((p) {
      if (userType.isEmpty) return true;
      return p.planType.toLowerCase() == userType.toLowerCase();
    }).toList();

    // If no plans found for this type, show all (fallback)
    final displayPlans = filteredPlans.isEmpty ? plans : filteredPlans;

    // Extra padding so last card isn't hidden behind bottom nav bar
    final bottomInset =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Fixed Header (always visible) ──────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.chooseYourSubscription.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTText,
                ),
              ),
              6.verticalSpace,
              Text(
                AppStrings.pickThePlanDescription.tr(),
                style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
              ),
              20.verticalSpace,
              // ─── Duration Toggle ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildDurationButton(
                      discounts: discounts,
                      duration: SubscriptionDuration.monthly,
                      isSelected:
                          _selectedDuration == SubscriptionDuration.monthly,
                      onTap: () => setState(
                        () => _selectedDuration = SubscriptionDuration.monthly,
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: _buildDurationButton(
                      discounts: discounts,
                      duration: SubscriptionDuration.biannual,
                      isSelected:
                          _selectedDuration == SubscriptionDuration.biannual,
                      onTap: () => setState(
                        () => _selectedDuration = SubscriptionDuration.biannual,
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: _buildDurationButton(
                      discounts: discounts,
                      duration: SubscriptionDuration.yearly,
                      isSelected:
                          _selectedDuration == SubscriptionDuration.yearly,
                      onTap: () => setState(
                        () => _selectedDuration = SubscriptionDuration.yearly,
                      ),
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
            ],
          ),
        ),

        // ─── Scrollable Plan Cards ───────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, bottomInset),
            physics: const BouncingScrollPhysics(),
            itemCount: displayPlans.length,
            separatorBuilder: (_, __) => 16.verticalSpace,
            itemBuilder: (context, i) {
              final plan = displayPlans[i];
              return _buildPlanCard(
                context: context,
                plan: plan,
                isSelected: _selectedPlanId == plan.id,
                isCurrentPlan: currentPlanId == plan.id,
                selectedDuration: _selectedDuration,
                discounts: discounts,
                onTap: () => setState(() => _selectedPlanId = plan.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationButton({
    required PlanDiscountsModel discounts,
    required SubscriptionDuration duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double discountVal = duration == SubscriptionDuration.biannual
        ? discounts.threeMonthsDiscount
        : duration == SubscriptionDuration.yearly
        ? discounts.yearlyDiscount
        : 0.0;
    final hasDiscount = discountVal > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              duration == SubscriptionDuration.monthly
                  ? AppStrings.monthly.tr()
                  : duration == SubscriptionDuration.biannual
                  ? AppStrings.biannual.tr()
                  : AppStrings.yearly.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.lightTText,
              ),
            ),
            if (hasDiscount) ...[
              4.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.redColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${discountVal.toInt()}% ${AppStrings.percentOff.tr()}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.redColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required SubscriptionPlanModel plan,
    required bool isSelected,
    required bool isCurrentPlan,
    required SubscriptionDuration selectedDuration,
    required PlanDiscountsModel discounts,
    required VoidCallback onTap,
  }) {
    final basePrice = double.tryParse(plan.price) ?? 0;
    double finalPrice = basePrice;
    int durationMonths = 1;

    if (selectedDuration == SubscriptionDuration.biannual) {
      durationMonths = 3;
      final originalPrice = basePrice * 3;
      finalPrice =
          originalPrice -
          (originalPrice * (discounts.threeMonthsDiscount / 100));
    } else if (selectedDuration == SubscriptionDuration.yearly) {
      durationMonths = 12;
      final originalPrice = basePrice * 12;
      finalPrice =
          originalPrice - (originalPrice * (discounts.yearlyDiscount / 100));
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrentPlan)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.green,
                        size: 14.sp,
                      ),
                      6.horizontalSpace,
                      Text(
                        'Current Plan',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.lightTText,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        plan.tier.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${plan.currency} ${finalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      durationMonths == 1
                          ? '/ ${AppStrings.monthly.tr()}'
                          : durationMonths == 3
                          ? '/ 3 ${AppStrings.monthly.tr()}'
                          : '/ ${AppStrings.yearly.tr()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            16.verticalSpace,
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
                    12.horizontalSpace,
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
            16.verticalSpace,
            Center(
              child: BlocBuilder<ActivatePlanCubit, ActivatePlanState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (state is ActivatePlanLoading || isCurrentPlan)
                          ? null
                          : () {
                              debugPrint(
                                'DEBUG: Activating plan with ID: ${plan.id}, Duration: $durationMonths',
                              );
                              context.read<ActivatePlanCubit>().activatePlan(
                                planId: plan.id.toString(),
                                durationMonths: durationMonths,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: state is ActivatePlanLoading && isSelected
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: AnimatedLoading(color: Colors.white),
                            )
                          : Container(
                              height: 48.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: isCurrentPlan
                                    ? null
                                    : LinearGradient(
                                        colors: [
                                          AppColors.primaryColor,
                                          AppColors.primaryColor.withOpacity(
                                            0.8,
                                          ),
                                        ],
                                      ),
                                color: isCurrentPlan ? Colors.grey[200] : null,
                              ),
                              child: Text(
                                isCurrentPlan
                                    ? 'Current Plan'
                                    : 'Activate Plan',
                                style: TextStyle(
                                  color: isCurrentPlan
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
