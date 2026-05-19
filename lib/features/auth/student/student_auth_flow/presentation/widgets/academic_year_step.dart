import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/student_onboarding_cubit.dart';
import '../cubit/student_onboarding_state.dart';
import 'institute_checkbox.dart';

class AcademicYearStep extends StatefulWidget {
  const AcademicYearStep({super.key});

  @override
  State<AcademicYearStep> createState() => _AcademicYearStepState();
}

class _AcademicYearStepState extends State<AcademicYearStep> {
  final _graduatedYearController = TextEditingController();
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
    _graduatedYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<StudentOnboardingCubit>();
        final academicYears = state.data.academicYears;
        final graduatedYear = state.data.graduatedYear;
        final isGraduated = academicYears.any(
          (year) => year.isSelected && year.name == 'graduated',
        );

        if (graduatedYear != null && _graduatedYearController.text.isEmpty) {
          _graduatedYearController.text = graduatedYear;
        }

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          opacity: _isVisible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            offset: _isVisible ? Offset.zero : const Offset(0, 0.04),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.height,
                  Text(
                    'academicYear'.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  8.height,
                  Text(
                    'selectYourAcademicYear'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  24.height,
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...academicYears.asMap().entries.map((entry) {
                          final index = entry.key;
                          final year = entry.value;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 16, end: 0),
                            duration: Duration(milliseconds: 180 + index * 60),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: Opacity(
                                  opacity: 1 - (value / 16).clamp(0, 1),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: InstituteCheckbox(
                                label: year.name.tr(),
                                isSelected: year.isSelected,
                                onChanged: (_) {
                                  cubit.toggleAcademicYear(year.id);
                                },
                              ),
                            ),
                          );
                        }),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: isGraduated
                              ? Column(
                                  key: const ValueKey('graduated_field'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    16.height,
                                    Text(
                                      'graduatedYear'.tr(),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lightTText,
                                      ),
                                    ),
                                    8.height,
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 10, end: 0),
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, value),
                                          child: Opacity(
                                            opacity:
                                                1 - (value / 10).clamp(0, 1),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: CustomTextField(
                                        label: '',
                                        hint: 'enterYourGraduatedYear'.tr(),
                                        controller: _graduatedYearController,
                                        keyboardType: TextInputType.number,
                                        onChanged: cubit.updateGraduatedYear,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(
                                  key: ValueKey('no_graduated_field'),
                                ),
                        ),
                      ],
                    ),
                  ),
                  24.height,
                  Text(
                    'chooseYourExperienceLevel'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  16.height,
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.data.experienceLevels.length,
                    separatorBuilder: (context, index) => 12.height,
                    itemBuilder: (context, index) {
                      final level = state.data.experienceLevels[index];
                      final isSelected = level.isSelected;
                      return GestureDetector(
                        onTap: () => cubit.toggleExperienceLevel(level.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.lightBGColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondaryColor.withOpacity(0.5)
                                  : AppColors.borderColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondaryColor
                                        : AppColors.borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              16.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.name,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lightTText,
                                      ),
                                    ),
                                    Text(
                                      level.description,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  40.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
