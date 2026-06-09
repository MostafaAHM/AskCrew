import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/routes.dart';
import 'package:aflam/core/helpers/user_helper.dart';

class UserProfileHeaderCard extends StatelessWidget {
  final UserModel? user;
  final String userName;
  final String? profilePhoto;
  final double? rating;
  final int? reviewCount;
  final bool isOwner;
  final VoidCallback? onWithdrawTap;
  final String? experienceLevel;

  const UserProfileHeaderCard({
    super.key,
    required this.user,
    required this.userName,
    this.profilePhoto,
    this.rating,
    this.reviewCount,
    required this.isOwner,
    this.onWithdrawTap,
    this.experienceLevel,
  });

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF333333);
    const secondaryText = Color(0xFF888888);
    const accentColor = Color(0xFFFF7A2F);

    final ratingValue = rating ?? 0.0;
    final fullStars = ratingValue.floor();
    final hasHalfStar = (ratingValue - fullStars) >= 0.5;

    final currentUser = UserHelper.userNotifier.value;
    final isCurrentUserStudent = currentUser?.type.toLowerCase() == 'student';
    final isTargetUserStudent = user?.type.toLowerCase() == 'student';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profilePhoto != null
                        ? CachedNetworkImageProvider(
                            profilePhoto!.startsWith('http')
                                ? profilePhoto!
                                : AppUrls.imageLink(profilePhoto!),
                          )
                        : null,
                    child: profilePhoto == null
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          )
                        : null,
                  ),
                  // Status indicator (green for available, red for not available)
                  if (user != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: BoxDecoration(
                          color: (user?.isActive ?? false)
                              ? Colors.green
                              : Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                (user?.isActive ?? false)
                    ? 'common_available'.tr()
                    : 'common_not_available'.tr(),
                style: TextStyle(
                  color: primaryText,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Name and info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 22.sp, // +4
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user?.waterMark == true) ...[
                      6.horizontalSpace,
                      Icon(Icons.verified, color: Colors.blue, size: 24.sp),
                    ],
                  ],
                ),
                if (experienceLevel != null && experienceLevel!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      experienceLevel == '—' ? '—' : experienceLevel!.tr(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (rating != null && rating! > 0) ...[
                  SizedBox(height: 4.h),
                  // Stars row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          fullStars,
                          (index) =>
                              Icon(Icons.star, size: 20.sp, color: accentColor),
                        ),
                        if (hasHalfStar)
                          Icon(Icons.star_half, size: 20.sp, color: accentColor),
                        ...List.generate(
                          5 - fullStars - (hasHalfStar ? 1 : 0),
                          (index) => Icon(
                            Icons.star_border,
                            size: 20.sp,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ratingValue.toStringAsFixed(1),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Reviews text
                  if (reviewCount != null && reviewCount! > 0)
                    Text(
                      '($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})',
                      style: TextStyle(color: secondaryText, fontSize: 16.sp),
                    ),
                ],
              ],
            ),
          ),
          // Edit icon (if own profile) or Chat icon (if viewing someone else's profile)
          // Show chat button if not owner and user is not null
          // AND NOT (Current user is Student viewing non-Student (Talent))
          (!isOwner &&
                  user != null &&
                  !(isCurrentUserStudent && !isTargetUserStudent))
              ? IconButton(
                  onPressed: () async {
                    final targetUser = user!;
                    try {
                      final chatCubit = context.read<ChatCubit>();
                      await chatCubit.getOrCreateChatRoom(targetUser.id);

                      await chatCubit.stream.firstWhere(
                        (state) =>
                            state.selectedRoom != null ||
                            state.status == ChatStatus.error,
                      ); // Reusing existing logic... just guarding UI

                      if (context.mounted) {
                        final room = chatCubit.state.selectedRoom;
                        if (room != null) {
                          context.pushNamed(
                            Routes.chat,
                            extra: {
                              'roomId': room.id,
                              'roomName': targetUser.fullname,
                              'otherUserImage': targetUser.profilePhoto,
                              'otherUser': targetUser,
                            },
                          );
                        }
                      }
                    } catch (e) {
                      // Handle error - could show a snackbar
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to open chat: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: SvgImageWidget(
                    image: AppIcons.chat,
                    width: 24.w,
                    height: 24.h,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Chat',
                )
              : isOwner
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onWithdrawTap != null)
                      InkWell(
                        onTap: onWithdrawTap,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEADDFF),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'withdraw'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF6750A4),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (onWithdrawTap != null) SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () async {
                        if (user != null) {
                          final userType = user!.type.toLowerCase();
                          if (userType == 'enterprise') {
                            context.pushNamed(Routes.yourProfile, extra: user);
                          } else if (userType == 'student') {
                            final result = await context.pushNamed(
                              Routes.editStudentProfile,
                            );
                            if (result == true && context.mounted) {
                              // Assuming logic to refresh profile is handled by parent or we can try access cubit
                              // But UserProfileScreen uses ProfileCubit.
                              // We might need to check if ProfileCubit is in context.
                              // For now, let's rely on UserHelper updates or navigation result.
                              // Ideally we re-fetch.
                              // Since UserProfileHeaderCard is dumb, we just invoke navigation.
                              // But we want to refresh.
                            }
                          } else if (userType == 'viewer') {
                            context.pushNamed(Routes.editViewerProfile);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 24.sp,
                        color: AppColors.primaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                )
              : const SizedBox.shrink(), // Hide button if user is null
        ],
      ),
    );
  }
}
