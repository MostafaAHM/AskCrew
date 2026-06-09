import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/enterprise_onboarding_cubit.dart';
import '../cubit/enterprise_onboarding_state.dart';
import 'specification_checkbox.dart';

class SpecificationStep extends StatefulWidget {
  const SpecificationStep({super.key});

  @override
  State<SpecificationStep> createState() => _SpecificationStepState();
}

class _SpecificationStepState extends State<SpecificationStep> {
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

  String _formatName(String name) {
    if (name.isEmpty) return '';
    return name
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnterpriseOnboardingCubit, EnterpriseOnboardingState>(
      builder: (context, state) {
        if (state is! EnterpriseOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final specifications = state.data.specifications;

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
                        AppStrings.chooseYourSpecification.tr(),
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
                    AppStrings.tellUsYourAreaOfExpertise.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  32.height,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: specifications.length,
                    itemBuilder: (context, index) {
                      final category = specifications[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<EnterpriseOnboardingCubit>()
                                  .toggleCategoryExpanded(
                                    category.categoryName,
                                  );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 16.w,
                              ),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                color: AppColors.lightBGColor,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatName(category.categoryName),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.lightTText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    category.isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (category.isExpanded)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    childAspectRatio: 2.5,
                                  ),
                              padding: EdgeInsets.only(bottom: 16.h),
                              itemCount: category.items.length,
                              itemBuilder: (context, itemIndex) {
                                final spec = category.items[itemIndex];
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 20, end: 0),
                                  duration: Duration(
                                    milliseconds: 150 + (itemIndex * 30),
                                  ),
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
                                  child: SpecificationCheckbox(
                                    label: _formatName(spec.name),
                                    isSelected: spec.isSelected,
                                    onChanged: (value) {
                                      context
                                          .read<EnterpriseOnboardingCubit>()
                                          .toggleSpecification(
                                            category.categoryName,
                                            spec.id,
                                          );
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
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
