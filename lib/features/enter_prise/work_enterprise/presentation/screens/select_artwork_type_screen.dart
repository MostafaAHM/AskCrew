import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/app_config/app_strings.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';

class SelectArtworkTypeScreen extends StatefulWidget {
  const SelectArtworkTypeScreen({super.key});

  @override
  State<SelectArtworkTypeScreen> createState() =>
      _SelectArtworkTypeScreenState();
}

class _SelectArtworkTypeScreenState extends State<SelectArtworkTypeScreen>
    with SingleTickerProviderStateMixin {
  ArtworkType? _selectedType;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSlideIn(
              index: 0,
              controller: _animationController,
              child: _buildProgressIndicator(currentStep: 1, totalSteps: 4),
            ),

            SizedBox(height: 30.h),

            AnimatedSlideIn(
              index: 1,
              controller: _animationController,
              child: Text(
                AppStrings.selectYourArtworkType.tr(),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            AnimatedSlideIn(
              index: 2,
              controller: _animationController,
              child: Text(
                AppStrings.chooseTypeOfCreativeProject.tr(),
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              ),
            ),

            SizedBox(height: 40.h),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20.h,
                crossAxisSpacing: 20.w,
                childAspectRatio: 1.1,
                children: [
                  AnimatedSlideIn(
                    index: 3,
                    controller: _animationController,
                    child: _buildArtworkTypeCard(
                      type: ArtworkType.series,
                      icon: AppIcons.series,
                      label: AppStrings.projectSeries.tr(),
                      isPng: true,
                    ),
                  ),
                  AnimatedSlideIn(
                    index: 4,
                    controller: _animationController,
                    child: _buildArtworkTypeCard(
                      type: ArtworkType.movie,
                      icon: AppIcons.movie,
                      label: AppStrings.projectMovie.tr(),
                      isPng: false,
                    ),
                  ),
                  AnimatedSlideIn(
                    index: 5,
                    controller: _animationController,
                    child: _buildArtworkTypeCard(
                      type: ArtworkType.advertising,
                      icon: AppIcons.advertising,
                      label: AppStrings.projectAdvertise.tr(),
                      isPng: true,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSlideIn(
              index: 6,
              controller: _animationController,
              child: CustomButton(
                text: AppStrings.next.tr(),
                onTap: _selectedType != null ? _onNext : null,
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required int currentStep,
    required int totalSteps,
  }) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? const Color(0xFFFF5722)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkTypeCard({
    required ArtworkType type,
    required String icon,
    required String label,
    required bool isPng,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF5722).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5722) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isPng
                    ? Image.asset(
                        icon,
                        width: 40.w,
                        height: 40.h,
                        color: const Color(0xFFFF5722),
                      )
                    : Image.asset(icon, width: 40.w, height: 40.h),
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              label,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF5722) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (_selectedType == null) return;

    switch (_selectedType!) {
      case ArtworkType.movie:
        context.push('/upload-movie');
        break;
      case ArtworkType.series:
        context.push('/upload-series');
        break;
      case ArtworkType.advertising:
        context.push('/upload-advertising');
        break;
    }
  }
}

enum ArtworkType { series, movie, advertising }
