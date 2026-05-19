import 'dart:ui';

import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../config/routes/routes.dart';
import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_icons.dart';
import '../../../../core/app_config/font_styles.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _selectedIndex = 0;
  bool _isVisible = false;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  void navigateBasedOnSelection() {
    if (_selectedIndex == 0) {
      context.pushNamed(Routes.viewerHome);
    } else if (_selectedIndex == 1) {
      context.pushNamed(Routes.registerEnterprise);
    } else {
      context.pushNamed(Routes.registerStudent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBGColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppIcons.onBoarding1, fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        final currentLocale = context.locale;
                        final newLocale = currentLocale.languageCode == 'ar'
                            ? const Locale('en')
                            : const Locale('ar');
                        if (newLocale != currentLocale) {
                          await context.setLocale(newLocale);
                        }
                      },
                      child: Container(
                        width: 80.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: context.locale.languageCode == 'ar'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 36.w,
                                height: 36.h,
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    context.locale.languageCode == 'ar'
                                        ? '🇰🇼'
                                        : '🇺🇸',
                                    style: TextStyle(fontSize: 20.sp),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  16.height,
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isVisible ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        offset: _isVisible
                            ? Offset.zero
                            : const Offset(0, 0.05),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              100.height,

                              Image.asset(
                                AppIcons.onboardingLogo,
                                height: 58.h,
                              ),

                              24.height,

                              Text(
                                "welcome_title".tr(),
                                textAlign: TextAlign.center,
                                style: FontStyles.label24.copyWith(
                                  color: AppColors.whiteColor,
                                  height: 1.35,
                                ),
                              ),

                              10.height,

                              Container(
                                width: 110.w,
                                height: 3.h,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                              ),

                              26.height,

                              _OnboardingCard(
                                index: 0,
                                selectedIndex: _selectedIndex,
                                title: "viewer".tr(),
                                desc: "viewer_desc".tr(),
                                onTap: () => setState(() => _selectedIndex = 0),
                              ),

                              14.height,

                              _OnboardingCard(
                                index: 1,
                                selectedIndex: _selectedIndex,
                                title: "enterprise".tr(),
                                desc: "enterprise_desc".tr(),
                                onTap: () => setState(() => _selectedIndex = 1),
                              ),

                              14.height,

                              _OnboardingCard(
                                index: 2,
                                selectedIndex: _selectedIndex,
                                title: "student".tr(),
                                desc: "student_desc".tr(),
                                onTap: () => setState(() => _selectedIndex = 2),
                              ),

                              30.height,

                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 40, end: 0),
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, value),
                                    child: Opacity(
                                      opacity: 1 - (value / 40).clamp(0, 1),
                                      child: child,
                                    ),
                                  );
                                },
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _isButtonPressed = true),
                                  onTapUp: (_) {
                                    setState(() => _isButtonPressed = false);
                                    navigateBasedOnSelection();
                                  },
                                  onTapCancel: () =>
                                      setState(() => _isButtonPressed = false),
                                  child: AnimatedScale(
                                    scale: _isButtonPressed ? 0.96 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                    child: Container(
                                      width: 161.w,
                                      height: 46.h,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.buttonGradient,
                                        borderRadius: BorderRadius.circular(
                                          50.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.35,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "lets_start".tr(),
                                          style: FontStyles.headline16.copyWith(
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              40.height,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _OnboardingCard({
    required this.index,
    required this.selectedIndex,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.sliderGradient
                    : LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.9),
                          AppColors.primaryColor.withOpacity(0.7),
                          AppColors.primaryColor.withOpacity(0.5),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.5 : 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FontStyles.headline16.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: isSelected ? 18.sp : 16.sp,
                    ),
                  ),
                  6.height,
                  Text(
                    desc,
                    style: FontStyles.body14W500.copyWith(
                      color: AppColors.whiteColor.withOpacity(
                        isSelected ? 1 : 0.85,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
