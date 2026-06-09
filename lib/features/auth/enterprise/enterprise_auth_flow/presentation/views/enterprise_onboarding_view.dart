import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/enums/subscription_duration.dart';

import '../../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../../core/widgets/shimmer/subscription_selection_shimmer.dart';
import '../../../../../shared/plans/data/repo/plan_repository.dart';
import '../../../../../shared/plans/presentation/cubit/get_all_plan_cubit.dart';
import '../../data/models/request/enterprise_basic_data.dart';
import '../../data/repository/enterprise_repository.dart';
import '../cubit/enterprise_onboarding_cubit.dart';
import '../cubit/enterprise_onboarding_state.dart';
import '../../../../../../core/video_upload/presentation/cubit/video_upload_cubit.dart';

import '../widgets/company_info_step.dart';
import '../widgets/custom_stepper_indicator.dart';
import '../widgets/experience_level_step.dart';
import '../widgets/subscription_selection_step.dart';
import '../widgets/specification_step.dart';

class EnterpriseOnboardingView extends StatelessWidget {
  final EnterpriseBasicData? basicData;

  const EnterpriseOnboardingView({super.key, this.basicData});

  @override
  Widget build(BuildContext context) {
    // Check if this is a swap (from swap accounts screen)
    final isSwap =
        GoRouterState.of(context).uri.queryParameters['swap'] == 'true';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EnterpriseOnboardingCubit(
            repository: getIt<EnterpriseRepository>(),
            basicData: basicData,
            isSwapMode: isSwap,
          ),
        ),
        BlocProvider(
          create: (_) =>
              GetAllPlanCubit(getIt<PlanRepository>())..getAllPlans(),
        ),
        BlocProvider(create: (_) => getIt<VideoUploadCubit>()),
      ],
      child: BlocConsumer<EnterpriseOnboardingCubit, EnterpriseOnboardingState>(
        listenWhen: (previous, current) {
          if (current is EnterpriseOnboardingLoading) return true;
          if (previous is EnterpriseOnboardingLoading &&
              current is! EnterpriseOnboardingLoading) {
            return true;
          }
          if (current is EnterpriseOnboardingSuccess ||
              current is EnterpriseOnboardingFailure) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state is EnterpriseOnboardingLoading) {
            AppMessages.showLoading(context);
            return;
          }

          if (state is EnterpriseOnboardingSuccess) {
            AppMessages.hideLoading(context);

            final isSwap =
                GoRouterState.of(context).uri.queryParameters['swap'] == 'true';

            // Only show success message if it's not a paid plan (no paymentUrl)
            // or if it's swap mode
            if (state.paymentUrl == null ||
                state.paymentUrl!.isEmpty ||
                isSwap) {
              AppMessages.showSuccess(context, state.message);
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Check if there's a payment URL to handle
              if (state.paymentUrl != null && state.paymentUrl!.isNotEmpty) {
                // Navigate to payment webview first
                await context.pushNamed<bool>(
                  Routes.paymentWebView,
                  extra: {
                    'paymentUrl': state.paymentUrl!,
                    'onPaymentSuccess': () {},
                    'onPaymentCancel': () {},
                  },
                );

                // Show success message after returning from payment for non-swap
                if (context.mounted && !isSwap) {
                  AppMessages.showSuccess(context, state.message);
                }
              }

              if (!context.mounted) return;

              if (isSwap) {
                // For swap, we just go home regardless of payment flow (assuming payment success or not blocking)
                GoRouter.of(context).go(Routes.enterpriseHome);
              } else {
                // Navigate to login instead of OTP
                GoRouter.of(context).go(Routes.login);
              }
            });
          } else if (state is EnterpriseOnboardingFailure) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        buildWhen: (previous, current) {
          if (previous is EnterpriseOnboardingInitial &&
              current is EnterpriseOnboardingInProgress) {
            return true;
          }
          return current is EnterpriseOnboardingInProgress;
        },
        builder: (context, state) {
          if (state is EnterpriseOnboardingInitial) {
            return const Scaffold(
              backgroundColor: AppColors.lightBGColor,
              body: Center(child: AnimatedLoading()),
            );
          }

          final inProgressState = state as EnterpriseOnboardingInProgress;

          final cubit = context.read<EnterpriseOnboardingCubit>();
          final currentStep = inProgressState.currentStep;

          return Scaffold(
            backgroundColor: AppColors.lightBGColor,
            appBar: CustomAppBar.backAppBar(
              showLogoInBackAppBar: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.lightTText,
                ),
                onPressed: () {
                  if (currentStep > 0) {
                    cubit.previousStep();
                  } else {
                    context.go(Routes.registerEnterprise);
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: CustomStepperIndicator(
                      totalSteps: 5,
                      currentStep: currentStep + 1,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _buildStepContent(context, inProgressState),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        CustomButton.filled(
                          width: double.infinity,
                          height: 56.h,
                          text: currentStep == 3
                              ? AppStrings.submit.tr()
                              : AppStrings.next.tr(),
                          isBackgroundGradient: true,
                          gradient: AppColors.primaryGradient,
                          onTap: () {
                            final error = context
                                .read<EnterpriseOnboardingCubit>()
                                .getValidationError();
                            if (error != null) {
                              AppMessages.showError(context, error);
                              return;
                            }

                            if (currentStep == 3) {
                              context
                                  .read<EnterpriseOnboardingCubit>()
                                  .submitOnboarding();
                            } else {
                              context
                                  .read<EnterpriseOnboardingCubit>()
                                  .nextStep();
                            }
                          },
                        ),
                        if (currentStep == 0 ||
                            currentStep == 2 ||
                            currentStep == 3) ...[
                          24.height,
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.greyText,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppStrings.alreadyRegistered.tr(),
                                  ),
                                  TextSpan(
                                    text: AppStrings.loginHere.tr(),
                                    style: TextStyle(
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.go(Routes.login);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    EnterpriseOnboardingInProgress state,
  ) {
    final step = state.currentStep;

    switch (step) {
      case 0:
        return const SpecificationStep();
      case 1:
        return const ExperienceLevelStep();
      case 2:
        return const CompanyInfoStep();
      case 3:
        return BlocBuilder<GetAllPlanCubit, GetAllPlanState>(
          builder: (context, planState) {
            if (planState is GetAllPlanLoading ||
                planState is GetAllPlanInitial) {
              return const SubscriptionSelectionShimmer();
            }

            if (planState is GetAllPlanFailure) {
              return Center(
                child: Text(
                  planState.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (planState is GetAllPlanSuccess) {
              final plans = planState.plansResponse.results
                  .where((p) => p.planType == 'enterprise')
                  .toList();

              final cubit = context.read<EnterpriseOnboardingCubit>();

              final selectedPlanId = state.data.selectedPlanId;
              final selectedDuration =
                  state.data.subscriptionDuration ??
                  SubscriptionDuration.monthly;

              return SubscriptionSelectionStep(
                plans: plans,
                discounts: planState.discounts,
                selectedPlanId: selectedPlanId,
                selectedDuration: selectedDuration,
                onDurationChanged: (duration) {
                  cubit.selectSubscriptionDuration(duration);
                },
                onPlanSelected: (planId) {
                  cubit.selectSubscriptionPlan(planId);
                },
                onSkip: () {
                  final freePlan = plans.firstWhere(
                    (p) => double.tryParse(p.price) == 0,
                    orElse: () => plans.first,
                  );
                  cubit.selectSubscriptionPlan(freePlan.id);
                  cubit.submitOnboarding();
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
