import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/core/di/service_locator.dart';

import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/app_config/font_styles.dart';
import '../../../../../../core/widgets/shimmer/subscription_selection_shimmer.dart';
import '../../../../enterprise/enterprise_auth_flow/presentation/widgets/subscription_selection_step.dart';
import '../../../../../shared/plans/data/repo/plan_repository.dart';
import '../../../../../shared/plans/presentation/cubit/get_all_plan_cubit.dart';
import '../../../register_student/data/repository/student_repository_impl.dart';
import '../../data/models/request/student_basic_data.dart';
import '../cubit/student_onboarding_cubit.dart';
import '../cubit/student_onboarding_state.dart';
import '../widgets/academic_year_step.dart';
import '../widgets/student_personal_info_step.dart';
import '../widgets/student_specification_step.dart';
import '../widgets/custom_stepper_indicator.dart';

class StudentOnboardingView extends StatelessWidget {
  final StudentBasicData? basicData;

  const StudentOnboardingView({super.key, this.basicData});

  @override
  Widget build(BuildContext context) {
    // Check if this is a swap (from swap accounts screen)
    final isSwap =
        GoRouterState.of(context).uri.queryParameters['swap'] == 'true';

    return MultiBlocProvider(
      providers: [
        BlocProvider<StudentOnboardingCubit>(
          create: (context) => StudentOnboardingCubit(
            basicData: basicData,
            studentRepository: StudentRepositoryImpl(),
            isSwapMode: isSwap,
          ),
        ),
        BlocProvider<GetAllPlanCubit>(
          create: (context) =>
              GetAllPlanCubit(getIt<PlanRepository>())..getAllPlans(),
        ),
      ],
      child: BlocConsumer<StudentOnboardingCubit, StudentOnboardingState>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          if (state is StudentOnboardingLoading) {
            AppMessages.showLoading(context);
            return;
          }

          if (state is StudentOnboardingSuccess) {
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
              if (state.paymentUrl != null && state.paymentUrl!.isNotEmpty) {
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
                final user = UserHelper.userNotifier.value;
                if (user != null) {
                  GoRouter.of(context).go(Routes.studentHome);
                } else {
                  GoRouter.of(context).go(Routes.studentHome);
                }
              } else {
                // Navigate to login instead of OTP
                GoRouter.of(context).go(Routes.login);
              }
            });
          } else if (state is StudentOnboardingFailure) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        buildWhen: (previous, current) {
          if (previous is StudentOnboardingInitial &&
              current is StudentOnboardingInProgress) {
            return true;
          }
          return current is StudentOnboardingInProgress;
        },
        builder: (context, state) {
          if (state is StudentOnboardingInitial) {
            return const Scaffold(
              backgroundColor: AppColors.lightBGColor,
              body: Center(child: AnimatedLoading()),
            );
          }

          final inProgressState = state as StudentOnboardingInProgress;
          final cubit = context.read<StudentOnboardingCubit>();
          final currentStep = inProgressState.currentStep;

          return Scaffold(
            backgroundColor: AppColors.lightBGColor,
            // appBar: AppBar(
            //   backgroundColor: AppColors.lightBGColor,
            //   elevation: 0,

            //   actions: [
            //     Padding(
            //       padding: EdgeInsets.only(right: 24.w),
            //       child: Image.asset(
            //         AppIcons.logoPNG,
            //         width: 75 .w,
            //         height: 50.h,
            //       ),
            //     ),
            //   ],
            // ),
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
                    context.go(Routes.registerStudent);
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
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.secondaryColor,
                              AppColors.primaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          onTap: () {
                            final error = cubit.getValidationError();
                            if (error != null) {
                              AppMessages.showError(context, error);
                              return;
                            }

                            if (currentStep == 3) {
                              cubit.submitOnboarding();
                            } else {
                              cubit.nextStep();
                            }
                          },
                        ),
                        if (currentStep == 0 || currentStep == 3) ...[
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
                                    style: FontStyles.textStyle14.copyWith(
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
    StudentOnboardingInProgress state,
  ) {
    final step = state.currentStep;

    switch (step) {
      case 0: // Consolidated Institute & Specifications
        return const StudentSpecificationStep();
      case 1: // Academic Year
        return const AcademicYearStep();
      case 2: // Consolidated Info & Social
        return const StudentPersonalInfoStep();
      case 3: // Subscription
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
                  .where((p) => p.planType == 'student')
                  .toList();

              final cubit = context.read<StudentOnboardingCubit>();
              final selectedPlanId = cubit.selectedPlanId;
              final selectedDuration = cubit.subscriptionDuration;

              return SubscriptionSelectionStep(
                plans: plans,
                discounts: planState.discounts,
                selectedPlanId: selectedPlanId,
                selectedDuration: selectedDuration,
                onDurationChanged: cubit.selectSubscriptionDuration,
                onPlanSelected: cubit.selectSubscriptionPlan,
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
