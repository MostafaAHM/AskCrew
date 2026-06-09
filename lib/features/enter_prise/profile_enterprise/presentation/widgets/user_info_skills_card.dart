import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/shared/plans/presentation/screens/plans_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'info_row_widget.dart';
import 'skills_column_widget.dart';
import 'social_icon_widget.dart';

class UserInfoSkillsCard extends StatefulWidget {
  final String location;
  final String education;
  final String profession;
  final List<String> skills;
  final String? facebookLink;
  final String? instagramLink;
  final String? linkedinLink;
  final String? emailLink;
  final String? youtubeLink;
  final String? experienceLevel;
  final List<String>? portfolioLinks;
  final int? jobApplications;
  final int? approvedApplications;
  final String? planName;
  final bool isOwner;
  final int? views;
  final int? totalBookings;
  final int? topWorkView;
  final Map<String, dynamic>? plan;
  final String? specialization;

  const UserInfoSkillsCard({
    super.key,
    required this.location,
    required this.education,
    required this.profession,
    required this.skills,
    this.facebookLink,
    this.instagramLink,
    this.linkedinLink,
    this.emailLink,
    this.youtubeLink,
    this.experienceLevel,
    this.portfolioLinks,
    this.jobApplications,
    this.approvedApplications,
    this.planName,
    this.isOwner = false,
    this.views,
    this.totalBookings,
    this.topWorkView,
    this.plan,
    this.specialization,
  });

  @override
  State<UserInfoSkillsCard> createState() => _UserInfoSkillsCardState();
}

class _UserInfoSkillsCardState extends State<UserInfoSkillsCard> {
  @override
  Widget build(BuildContext context) {
    // Use provided skills, or empty list (no hardcoded defaults)
    final displaySkills = widget.skills;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF50177A).withOpacity(0.04),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specialization
          if (widget.specialization != null && widget.specialization!.isNotEmpty) ...[
            InfoRowWidget(
              icon: Icons.work_outline,
              text: widget.specialization!,
            ),
            Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
          ],
          // Location, Education, Profession
          InfoRowWidget(
            icon: Icons.location_on_outlined,
            text: widget.location,
          ),
          Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
          InfoRowWidget(icon: Icons.school_outlined, text: widget.education),
          Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
          InfoRowWidget(
            icon: Icons.work_outline_rounded,
            text: widget.profession,
          ),
          if (widget.experienceLevel != null &&
              widget.experienceLevel!.isNotEmpty) ...[
            Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            InfoRowWidget(
              icon: Icons.stars_outlined,
              text: widget.experienceLevel == '—'
                  ? '—'
                  : widget.experienceLevel!.tr(),
            ),
          ],
          if (widget.isOwner ||
              (widget.planName != null && widget.planName!.isNotEmpty)) ...[
            Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            InfoRowWidget(
              icon: Icons.star_outline,
              text: widget.planName != null && widget.planName!.isNotEmpty
                  ? '${'package'.tr()}: ${widget.planName}'
                  : '${'package'.tr()}: Free',
              trailing: widget.isOwner
                  ? GestureDetector(
                      onTap: () {
                        final profileCubit = context.read<ProfileCubit>();
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: profileCubit,
                              child: const PlansScreen(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          'Upgrade'.tr(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ],

          // Statistics Section
          if ((widget.views != null && widget.views! > 0) ||
              (widget.totalBookings != null && widget.totalBookings! > 0) ||
              (widget.topWorkView != null && widget.topWorkView! > 0)) ...[
            SizedBox(height: 16.h),
            Text(
              'statistics'.tr(),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            if (widget.views != null && widget.views! > 0) ...[
              InfoRowWidget(
                icon: Icons.visibility_outlined,
                text: '${'views'.tr()}: ${widget.views}',
              ),
              Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            ],
            if (widget.totalBookings != null && widget.totalBookings! > 0) ...[
              InfoRowWidget(
                icon: Icons.bookmark_border_outlined,
                text: '${'total_bookings'.tr()}: ${widget.totalBookings}',
              ),
              Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            ],
            if (widget.topWorkView != null && widget.topWorkView! > 0) ...[
              InfoRowWidget(
                icon: Icons.star_border_outlined,
                text: '${'top_work_view'.tr()}: ${widget.topWorkView}',
              ),
              Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            ],
          ],
          if ((widget.jobApplications != null && widget.jobApplications! > 0) ||
              (widget.approvedApplications != null &&
                  widget.approvedApplications! > 0)) ...[
            SizedBox(height: 16.h),
            Text(
              'professional_activity'.tr(),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            if (widget.jobApplications != null &&
                widget.jobApplications! > 0) ...[
              InfoRowWidget(
                icon: Icons.assignment_turned_in_outlined,
                text: '${'applied_jobs'.tr()}: ${widget.jobApplications}',
              ),
              Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            ],
            if (widget.approvedApplications != null &&
                widget.approvedApplications! > 0) ...[
              InfoRowWidget(
                icon: Icons.verified_user_outlined,
                text:
                    '${'accepted_roles'.tr()}: ${widget.approvedApplications}',
              ),
              Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
            ],
          ],
          SizedBox(height: 16.h),
          // Skills Section
          Text(
            'common_skills'.tr(),
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 19.sp, // +4
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SkillsColumnWidget(
                  skills: displaySkills
                      .take((displaySkills.length / 2).ceil())
                      .toList(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SkillsColumnWidget(
                  skills: displaySkills
                      .skip((displaySkills.length / 2).ceil())
                      .toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.facebookLink != null &&
                  widget.facebookLink!.isNotEmpty) ...[
                SocialIconWidget(
                  type: SocialMediaType.facebook,
                  onTap: () => _openSocialLink(widget.facebookLink!),
                ),
                SizedBox(width: 10.w),
              ],
              if (widget.instagramLink != null &&
                  widget.instagramLink!.isNotEmpty) ...[
                SocialIconWidget(
                  type: SocialMediaType.instagram,
                  onTap: () => _openSocialLink(widget.instagramLink!),
                ),
                SizedBox(width: 10.w),
              ],
              if (widget.linkedinLink != null &&
                  widget.linkedinLink!.isNotEmpty) ...[
                SocialIconWidget(
                  type: SocialMediaType.linkedin,
                  onTap: () => _openSocialLink(widget.linkedinLink!),
                ),
                SizedBox(width: 10.w),
              ],
              if (widget.emailLink != null && widget.emailLink!.isNotEmpty) ...[
                SocialIconWidget(
                  type: SocialMediaType.gmail,
                  onTap: () => _openEmailLink(widget.emailLink!),
                ),
                SizedBox(width: 10.w),
              ],
              if (widget.youtubeLink != null && widget.youtubeLink!.isNotEmpty)
                SocialIconWidget(
                  type: SocialMediaType.youtube,
                  onTap: () => _openSocialLink(widget.youtubeLink!),
                ),
            ],
          ),
          if (widget.portfolioLinks != null &&
              widget.portfolioLinks!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              'portfolioLinks'.tr(),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.portfolioLinks!.map((link) {
                return GestureDetector(
                  onTap: () => _openSocialLink(link),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          link.length > 25
                              ? '${link.substring(0, 22)}...'
                              : link,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xff4b4b4b),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSocialLink(String url) async {
    try {
      final uri = Uri.parse(url);

      // Try to launch with platform default first
      bool launched = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!launched) {
        // If platform default fails, try external application
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        // Last resort: try in-app web view
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      if (mounted) {
        AppMessages.showError(context, "Can't open link: ${e.toString()}");
      }
    }
  }

  Future<void> _openEmailLink(String emailLink) async {
    try {
      // Handle mailto: links
      final uri = Uri.parse(emailLink);

      // Try to launch with platform default first
      bool launched = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!launched) {
        // If platform default fails, try external application
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        if (mounted) {
          AppMessages.showError(context, "Can't open email");
        }
      }
    } catch (e) {
      if (mounted) {
        AppMessages.showError(context, "Can't open email: ${e.toString()}");
      }
    }
  }
}
