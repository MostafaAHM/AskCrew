import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/student_onboarding_cubit.dart';
import '../cubit/student_onboarding_state.dart';
import 'institute_checkbox.dart';

class InstituteSelectionStep extends StatefulWidget {
  const InstituteSelectionStep({super.key});

  @override
  State<InstituteSelectionStep> createState() => _InstituteSelectionStepState();
}

class _InstituteSelectionStepState extends State<InstituteSelectionStep> {
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
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final institutes = state.data.institutes;

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
                  Row(
                    children: [
                      Text(
                        'selectYourInstituteCollege'.tr(),
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
                    'selectYourOwnInstituteOrCollege'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  32.height,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: institutes.length,
                    itemBuilder: (context, index) {
                      final institute = institutes[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 18, end: 0),
                        duration: Duration(milliseconds: 180 + index * 60),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: Opacity(
                              opacity: 1 - (value / 18).clamp(0, 1),
                              child: child,
                            ),
                          );
                        },
                        child: InstituteCheckbox(
                          label: institute.name,
                          isSelected: institute.isSelected,
                          onChanged: (value) {
                            context
                                .read<StudentOnboardingCubit>()
                                .toggleInstitute(institute.id);
                          },
                        ),
                      );
                    },
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
}
