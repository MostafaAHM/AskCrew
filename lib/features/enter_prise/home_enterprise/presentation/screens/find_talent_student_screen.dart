import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../shared/talent_profile/presentation/screens/talent_profile_args.dart';

import '../../data/model/talent_model.dart';

class FindTalentStudentScreen extends StatelessWidget {
  final String title;
  final List<TalentModel> items;
  final bool isTalent;

  const FindTalentStudentScreen({
    super.key,
    required this.title,
    required this.items,
    this.isTalent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isTalent
          ? AppColors.lightBGColor
          : const Color(0xFFFFF8F0),
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: isTalent
                      ? AppColors.lightTText
                      : const Color(0xFF50177A),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.only(bottom: 24.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: isTalent ? 0.55 : 0.60,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final talent = items[index];
                          return _ProfileCard(
                            talent: talent,
                            isTalent: isTalent,
                            onTap: () {
                              if (isTalent) {
                                context.pushNamed(
                                  Routes.talentProfile,
                                  extra: TalentProfileArgs(id: talent.id),
                                );
                              } else {
                                final userId = int.tryParse(talent.id);
                                if (userId != null) {
                                  context.pushNamed(
                                    Routes.userProfile,
                                    extra: userId,
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final TalentModel talent;
  final bool isTalent;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.talent,
    required this.isTalent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return isTalent ? _buildTalentCard(context) : _buildStudentCard(context);
  }

  Widget _buildTalentCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 135.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.15),
                          AppColors.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child:
                        (talent.imageUrl != null && talent.imageUrl!.isNotEmpty)
                        ? CustomCachedNetworkImage(
                            url: talent.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 48.sp,
                              color: AppColors.primaryColor.withOpacity(0.5),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  talent.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.lightTText,
                                  ),
                                ),
                              ),
                              if (talent.waterMark) ...[
                                5.width,
                                Icon(
                                  Icons.verified,
                                  size: 15.sp,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ],
                            ],
                          ),
                          6.height,
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                final full = i < talent.rating.floor();
                                final half =
                                    i == talent.rating.floor() &&
                                    (talent.rating - talent.rating.floor()) >=
                                        0.5;
                                return Icon(
                                  half
                                      ? Icons.star_half_rounded
                                      : full
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14.sp,
                                  color: full || half
                                      ? AppColors.secondaryColor
                                      : const Color(0xFFD9D9D9),
                                );
                              }),
                              6.width,
                              Text(
                                talent.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (talent.role.isNotEmpty) ...[
                            8.height,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                talent.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                          if (talent.specialization.isNotEmpty) ...[
                            6.height,
                            Text(
                              talent.specialization,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.greyText,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: talent.isAvailable
                              ? AppColors.green
                              : Colors.red,
                        ),
                      ),
                      4.width,
                      Text(
                        talent.isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: talent.isAvailable
                              ? AppColors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF50177A).withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: Stack(
            children: [
              Positioned(
                top: -30.h,
                right: -30.w,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFE5B00).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40.h,
                left: -40.w,
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF50177A).withOpacity(0.06),
                  ),
                ),
              ),
              Column(
                children: [
                  16.height,
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF50177A).withOpacity(0.15),
                        width: 3.w,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          (talent.imageUrl != null &&
                              talent.imageUrl!.isNotEmpty)
                          ? CustomCachedNetworkImage(
                              url: talent.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFFF5F0FF),
                              child: Icon(
                                Icons.person,
                                size: 40.sp,
                                color: const Color(0xFF50177A).withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  12.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          talent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF50177A),
                          ),
                        ),
                      ),
                      if (talent.waterMark) ...[
                        5.width,
                        Icon(
                          Icons.verified,
                          size: 15.sp,
                          color: const Color(0xFF2F80ED),
                        ),
                      ],
                    ],
                  ),
                  6.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (i) {
                        final full = i < talent.rating.floor();
                        final half =
                            i == talent.rating.floor() &&
                            (talent.rating - talent.rating.floor()) >= 0.5;
                        return Icon(
                          half
                              ? Icons.star_half_rounded
                              : full
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14.sp,
                          color: full || half
                              ? const Color(0xFFFE5B00)
                              : const Color(0xFFE0E0E0),
                        );
                      }),
                      6.width,
                      Text(
                        talent.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFE5B00),
                        ),
                      ),
                    ],
                  ),
                  if (talent.role.isNotEmpty) ...[
                    8.height,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE5B00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        talent.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFE5B00),
                        ),
                      ),
                    ),
                  ],
                  if (talent.specialization.isNotEmpty) ...[
                    10.height,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          talent.specialization,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: const Color(0xFF50177A),
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Positioned(
                top: 14.h,
                left: 14.w,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: talent.isAvailable ? AppColors.green : Colors.red,
                    border: Border.all(color: AppColors.whiteColor, width: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
