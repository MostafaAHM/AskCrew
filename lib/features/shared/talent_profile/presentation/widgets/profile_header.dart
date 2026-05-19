import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/app_config/app_icons.dart';
import '../../../../../../core/app_config/app_colors.dart';
import '../../data/models/talent_profile_model.dart';

import '../../../../../../core/helpers/user_helper.dart';
import 'rating_row.dart';

class ProfileHeader extends StatelessWidget {
  final TalentProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.r,
                        height: 24.r,
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: profile.isOnline
                              ? const Color(0xFF34C759).withOpacity(0.2)
                              : const Color(0xFFFF3B30).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (profile.isOnline)
                              Positioned(
                                left: 6.w,
                                child: Text(
                                  "On",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF34C759),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (!profile.isOnline)
                              Positioned(
                                right: 6.w,
                                child: Text(
                                  "Off",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFFFF3B30),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: profile.isOnline
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: profile.isOnline
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      4.verticalSpace,
                      if (profile.isOnline)
                        Text(
                          'talent.profile.available'.tr(),
                          style: TextStyle(
                            color: const Color(0xFF6D6D6D),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profile.imageUrl,
                        width: 120.r,
                        height: 120.r,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 50.r,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: UserHelper.userNotifier,
                    builder: (context, user, _) {
                      final isStudent = user?.type == 'student';
                      if (isStudent || user == null) {
                        return const SizedBox.shrink();
                      }
                      return InkWell(
                        onTap: () {
                          context.read<ChatCubit>().getOrCreateChatRoom(
                            profile.id,
                          );
                        },
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            AppIcons.chat,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        12.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                color: AppColors.lightTText,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (profile.isVerified) ...[
              6.horizontalSpace,
              Icon(Icons.verified, color: Colors.blue, size: 20.sp),
            ],
          ],
        ),
        8.verticalSpace,
        RatingRow(rating: profile.rating),
        4.verticalSpace,
        Text(
          'talent.profile.reviews'.tr(
            namedArgs: {'count': profile.reviewsCount.toString()},
          ),
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        8.verticalSpace,
        Text(
          profile.jobTitle,
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
