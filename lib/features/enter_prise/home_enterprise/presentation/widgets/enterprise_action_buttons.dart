import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/extensions/space_extension.dart';
import '../../../../../core/extensions/translation_extension.dart';

import 'package:go_router/go_router.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/helpers/authorization_helper.dart';

class EnterpriseActionButtons extends StatelessWidget {
  const EnterpriseActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: 'enterprise_my_workshop'.trOrFallback('My Workshop'),
            onTap: () {
              bool isProducer = AuthorizationHelper.isProducer();
              // If Producer: Artwork (0), Workshop (1)
              // If Non-Producer: Workshop (0)
              int tabIndex = isProducer ? 1 : 0;

              context.goNamed(
                Routes.enterpriseExplore,
                queryParameters: {'tabIndex': '$tabIndex'},
              );
            },
          ),
        ),
        10.width,
        Expanded(
          child: _ActionButton(
            title: 'enterprise_my_job'.trOrFallback('My Job'),
            onTap: () {
              // Navigate to Community -> Jobs Tab (Index 1)
              context.goNamed(
                Routes.enterpriseCommunity,
                queryParameters: {'tabIndex': '1'},
              );
            },
          ),
        ),
        10.width,
        Expanded(
          child: _ActionButton(
            title: 'enterprise_my_products'.trOrFallback('My Products'),
            onTap: () {
              // Navigate to Bookings
              context.goNamed(Routes.enterpriseBookings);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
