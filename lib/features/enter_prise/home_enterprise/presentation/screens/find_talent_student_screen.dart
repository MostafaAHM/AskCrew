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
      backgroundColor: AppColors.lightBGColor,
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
                  color: AppColors.lightTText,
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
                          childAspectRatio: 0.63,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final talent = items[index];
                          return _ProfileCard(
                            talent: talent,
                            onTap: () {
                              final userId = int.tryParse(talent.id);
                              if (userId != null) {
                                context.pushNamed(
                                  Routes.userProfile,
                                  extra: userId,
                                );
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
  final VoidCallback onTap;

  const _ProfileCard({required this.talent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 130.h,
                    width: double.infinity,
                    color: const Color(0xFFE9E9E9),
                    child:
                        (talent.imageUrl != null && talent.imageUrl!.isNotEmpty)
                        ? CustomCachedNetworkImage(
                            url: talent.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 42.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  talent.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.lightTText,
                                  ),
                                ),
                              ),
                              if (talent.waterMark) ...[
                                6.width,
                                Icon(
                                  Icons.verified,
                                  size: 16.sp,
                                  color: const Color(0xFF2F80ED),
                                ),
                              ],
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      : Icons.star_rounded,
                                  size: 15.sp,
                                  color: full || half
                                      ? AppColors.secondaryColor
                                      : const Color(0xFFD9D9D9),
                                );
                              }),
                              8.width,
                              Text(
                                talent.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (talent.role.isNotEmpty) ...[
                            6.height,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.2,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                talent.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                          if (talent.specialization.isNotEmpty) ...[
                            2.height,
                            Text(
                              talent.specialization,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greyText,
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
                top: 10.h,
                left: 10.w,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: talent.isAvailable ? AppColors.green : Colors.red,
                    border: Border.all(color: AppColors.whiteColor, width: 2),
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
