import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/response/experience_level_model.dart';
import '../cubit/enterprise_onboarding_cubit.dart';
import '../cubit/enterprise_onboarding_state.dart';

class ExperienceLevelStep extends StatefulWidget {
  const ExperienceLevelStep({super.key});

  @override
  State<ExperienceLevelStep> createState() => _ExperienceLevelStepState();
}

class _ExperienceLevelStepState extends State<ExperienceLevelStep> {
  final _personalInfoController = TextEditingController();
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
  void dispose() {
    _personalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnterpriseOnboardingCubit, EnterpriseOnboardingState>(
      builder: (context, state) {
        if (state is! EnterpriseOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final experienceLevels = state.data.experienceLevels;
        final cubit = context.read<EnterpriseOnboardingCubit>();

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
                    children: [
                      Text(
                        AppStrings.defineYourExperience.tr(),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTText,
                        ),
                      ),
                      4.width,
                      Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  8.height,
                  Text(
                    AppStrings.defineExperienceSubtitle.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  32.height,
                  ...experienceLevels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final level = entry.value;
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(level.id),
                      tween: Tween(begin: 20, end: 0),
                      duration: Duration(milliseconds: 180 + index * 70),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 - (value / 20).clamp(0, 1),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _buildExperienceLevelOption(
                          level: level,
                          onTap: () {
                            cubit.selectExperienceLevel(level.id);
                          },
                        ),
                      ),
                    );
                  }),
                  32.height,
                  Text(
                    AppStrings.personalInfoOptional.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyText,
                    ),
                  ),
                  12.height,
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _personalInfoController,
                      maxLines: 6,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.lightMainText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'someInfoAboutYou'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.hintColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                      onChanged: (value) {
                        cubit.updatePersonalInfo(value);
                      },
                    ),
                  ),
                  24.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceLevelOption({
    required ExperienceLevelModel level,
    required VoidCallback onTap,
  }) {
    final isSelected = level.isSelected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryColor.withOpacity(0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondaryColor
                  : AppColors.borderColor,
              width: isSelected ? 1.2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondaryColor.withOpacity(0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryColor
                        : AppColors.borderColor,
                    width: 1.4,
                  ),
                  color: Colors.white,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: isSelected
                      ? Center(
                          key: const ValueKey('selected'),
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        )
                      : const SizedBox(key: ValueKey('unselected')),
                ),
              ),
              12.width,
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.lightTText
                          : AppColors.lightMainText,
                    ),
                    children: [
                      TextSpan(text: '${level.name} '),
                      TextSpan(
                        text: '( ${level.description} )',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isSelected
                    ? Container(
                        key: const ValueKey('badge'),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          AppStrings.selected.tr(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('no_badge')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
