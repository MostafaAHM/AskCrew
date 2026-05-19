import 'dart:ui';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/file_download_helper.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../utils/user_profile_data_extractor.dart';
import '../widgets/about_card.dart';
import '../widgets/user_info_skills_card.dart';
import '../widgets/user_profile_header_card.dart';
import 'all_works_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel? user;

  const UserProfileScreen({super.key, this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = getIt<ProfileCubit>();
            if (widget.user != null) {
              // Always fetch fresh profile from API to ensure roles/images/videos are up-to-date
              WidgetsBinding.instance.addPostFrameCallback((_) {
                cubit.getUserProfile(widget.user!.id);
              });
            }
            return cubit;
          },
        ),
        BlocProvider(create: (context) => getIt<ChatCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatCubit, ChatState>(
            listener: (context, chatState) {
              if (chatState.status == ChatStatus.success &&
                  chatState.selectedRoom != null) {
                final profileState = context.read<ProfileCubit>().state;
                final userData = profileState is ProfileLoaded
                    ? profileState.user
                    : widget.user;

                if (userData == null) return;

                final currentUser = UserHelper.userNotifier.value;
                final isCurrentUserStudent =
                    currentUser?.type.toLowerCase() == 'student';
                final isCurrentUserEnterprise =
                    currentUser?.type.toLowerCase() == 'enterprise';
                final isViewingOwnProfile = currentUser?.id == userData.id;
                final isViewingStudentProfile =
                    userData.type.toLowerCase() == 'student';

                // Handle Student viewing Student profile
                if (isCurrentUserStudent &&
                    !isViewingOwnProfile &&
                    isViewingStudentProfile) {
                  final room = chatState.selectedRoom!;
                  if (context.mounted) {
                    context.pushReplacementNamed(
                      Routes.chat,
                      extra: {
                        'roomId': room.id,
                        'roomName': userData.fullname,
                        'otherUserImage': userData.profilePhoto,
                        'specification': userData.profile?.specification,
                        'otherUser': userData,
                      },
                    );
                  }
                }
                // Handle Enterprise viewing Student profile
                else if (isCurrentUserEnterprise &&
                    !isViewingOwnProfile &&
                    isViewingStudentProfile) {
                  final room = chatState.selectedRoom!;
                  if (context.mounted) {
                    context.pushNamed(
                      Routes.chat,
                      extra: {
                        'roomId': room.id,
                        'roomName': userData.fullname,
                        'otherUserImage': userData.profilePhoto,
                        'specification': userData.profile?.specification,
                        'otherUser': userData,
                      },
                    );
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is ProfileLoaded) {
                  final isCurrentlyMe =
                      widget.user != null &&
                      widget.user?.id.toString() ==
                          UserHelper.userNotifier.value?.id.toString();
                  return _handleProfileNavigation(
                    context,
                    state.user,
                    state.isOwner || isCurrentlyMe,
                  );
                }

                if (state is ProfileLoading) {
                  return _buildLoadingState();
                }

                // Removed redundant check that forced loading state

                return _buildLoadingState();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.red),
          ),
          16.height,
          ElevatedButton(
            onPressed: () {
              if (widget.user != null) {
                context.read<ProfileCubit>().getUserProfile(widget.user!.id);
              }
            },
            child: Text('common_retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        CustomShimmerWidget(
          width: double.infinity,
          height: 200.h,
          borderRadius: BorderRadius.circular(12.r),
        ),
        16.height,
        CustomShimmerWidget(
          width: double.infinity,
          height: 150.h,
          borderRadius: BorderRadius.circular(12.r),
        ),
        16.height,
        CustomShimmerWidget(
          width: double.infinity,
          height: 200.h,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ],
    );
  }

  Widget _handleProfileNavigation(
    BuildContext context,
    UserModel userData,
    bool isOwner,
  ) {
    final currentUser = UserHelper.userNotifier.value;
    final isCurrentUserEnterprise =
        currentUser?.type.toLowerCase() == 'enterprise';
    final isViewingEnterpriseProfile =
        userData.type.toLowerCase() == 'enterprise';

    // Redirect Enterprise users viewing Enterprise profiles to yourProfile screen
    if (isCurrentUserEnterprise && isViewingEnterpriseProfile && isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacementNamed(Routes.yourProfile, extra: userData);
      });
      return const Center(child: CircularProgressIndicator());
    }

    // Show profile content - user can manually click chat button if needed
    return _buildProfileContent(userData, isOwner);
  }

  Widget _buildProfileContent(UserModel userData, bool isOwner) {
    final personalInfoMap = UserProfileDataExtractor.extractPersonalInfo(
      userData,
    );
    final profile = userData.profile;

    // Extract data with proper null handling - no hardcoded fallbacks
    final userName = userData.fullname.isNotEmpty ? userData.fullname : null;

    final baseType = userData.type.toLowerCase() == 'student'
        ? 'common_student'.tr()
        : userData.type.toLowerCase() == 'enterprise'
        ? 'common_enterprise'.tr()
        : null;

    bool isSpecNotEmpty(dynamic spec) {
      if (spec == null) return false;
      if (spec is String) return spec.trim().isNotEmpty;
      if (spec is List) return spec.isNotEmpty;
      if (spec is Map) return spec.isNotEmpty;
      return true;
    }

    String? userSpecification = isSpecNotEmpty(profile?.specification)
        ? (profile!.specification is String
              ? profile!.specification
              : UserProfileDataExtractor.extractUserSpecification(
                  userData,
                  personalInfoMap,
                ))
        : UserProfileDataExtractor.extractUserSpecification(
            userData,
            personalInfoMap,
          ).isNotEmpty
        ? UserProfileDataExtractor.extractUserSpecification(
            userData,
            personalInfoMap,
          )
        : baseType;

    final experienceLevel = profile?.experienceLevel?.isNotEmpty == true
        ? profile!.experienceLevel
        : UserProfileDataExtractor.extractExperienceLevel(personalInfoMap);

    if (experienceLevel != null && experienceLevel.isNotEmpty) {
      final level = experienceLevel.tr();
      if (userSpecification != null &&
          userSpecification != '—' &&
          userSpecification != level) {
        userSpecification = '$level - $userSpecification';
      } else {
        userSpecification = level;
      }
    }

    final portfolioLinks =
        profile?.portfolioLinks != null && profile!.portfolioLinks!.isNotEmpty
        ? profile.portfolioLinks
        : UserProfileDataExtractor.extractPortfolioLinks(personalInfoMap);

    final jobApplications = profile?.jobApplicationsCount ?? 0;
    final approvedApplications = profile?.approvedJobApplicationsCount ?? 0;

    final profilePhoto = userData.profilePhoto;

    // About text: prefer profile.skills, then personalInfo, otherwise null
    bool isSkillsNotEmpty(dynamic skills) {
      if (skills == null) return false;
      if (skills is String) return skills.trim().isNotEmpty;
      if (skills is List) return skills.isNotEmpty;
      if (skills is Map) return skills.isNotEmpty;
      return true;
    }

    final aboutText = isSkillsNotEmpty(profile?.skills)
        ? (profile!.skills is String
              ? profile!.skills!
              : profile!.skills.toString())
        : UserProfileDataExtractor.extractAboutText(personalInfoMap) ??
              UserProfileDataExtractor.extractRawPersonalInfo(userData);

    // Location: prefer profile data, then personalInfo
    final location =
        profile != null && profile.city != null && profile.country != null
        ? '${profile.city}, ${profile.country}'
        : UserProfileDataExtractor.extractLocation(personalInfoMap);

    // Education: prefer profile.institute, then personalInfo
    String? education = profile?.institute?.isNotEmpty == true
        ? profile!.institute
        : UserProfileDataExtractor.extractEducation(personalInfoMap);

    if (profile?.academicYear != null && profile!.academicYear!.isNotEmpty) {
      education = education != null
          ? '$education (${profile.academicYear!.tr()})'
          : profile.academicYear!.tr();
    }

    final profession = userSpecification;

    // Skills: prefer profile.skills, then personalInfo
    final skillsList = UserProfileDataExtractor.extractSkills(
      personalInfoMap['skills'],
    );
    final skills = profile?.skills != null
        ? UserProfileDataExtractor.extractSkills(profile!.skills)
        : skillsList;

    final cvPath = profile?.cv?.isNotEmpty == true
        ? profile!.cv
        : UserProfileDataExtractor.extractCvPath(personalInfoMap);
    final cvName = cvPath != null && cvPath.isNotEmpty
        ? cvPath.split('/').last
        : null;

    final facebookLink = profile?.facebookLink?.isNotEmpty == true
        ? profile!.facebookLink
        : UserProfileDataExtractor.extractFacebookLink(personalInfoMap);
    final instagramLink = profile?.instagramLink?.isNotEmpty == true
        ? profile!.instagramLink
        : UserProfileDataExtractor.extractInstagramLink(personalInfoMap);
    final linkedinLink = profile?.linkedinLink?.isNotEmpty == true
        ? profile!.linkedinLink
        : UserProfileDataExtractor.extractLinkedinLink(personalInfoMap);
    final emailLink = userData.email.isNotEmpty
        ? 'mailto:${userData.email}'
        : null;
    final youtubeLink = profile?.youtubeLink?.isNotEmpty == true
        ? profile!.youtubeLink
        : UserProfileDataExtractor.extractYoutubeLink(personalInfoMap);

    // Rating and review count: use actual values or null (no hardcoded defaults)
    final rating = userData.ratingMean;
    final reviewCount = userData.ratingCount;

    // Extract plan tier (e.g. "free", "premium", "diamond")
    String? planName = profile?.plan?['tier']?.toString();
    if (planName == null || planName.isEmpty) {
      planName = profile?.paymentPlan;
    }

    // Capitalize the first letter if it exists
    if (planName != null && planName.isNotEmpty) {
      planName = planName[0].toUpperCase() + planName.substring(1);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserProfileHeaderCard(
            user: userData,
            userName: userName ?? '—',
            userSpecification: userSpecification ?? '—',
            profilePhoto: profilePhoto,
            rating: rating,
            reviewCount: reviewCount,
            isOwner: isOwner,
            experienceLevel: experienceLevel,
            onWithdrawTap: isOwner && userData.type.toLowerCase() == 'student'
                ? () {
                    context.pushNamed(Routes.recentTransactions);
                  }
                : null,
          ),
          SizedBox(height: 16.h),
          AboutCard(
            aboutText: aboutText,
            cvPath: cvPath,
            cvName: cvName,
            onCvDownload: () async {
              if (cvPath != null &&
                  cvPath.isNotEmpty &&
                  cvName != null &&
                  cvName.isNotEmpty) {
                await FileDownloadHelper.downloadCv(cvPath, cvName);
              }
            },
          ),
          SizedBox(height: 16.h),
          UserInfoSkillsCard(
            location: location ?? '—',
            education: education ?? '—',
            profession: profession ?? '—',
            skills: skills,
            facebookLink: facebookLink,
            instagramLink: instagramLink,
            linkedinLink: linkedinLink,
            emailLink: emailLink,
            youtubeLink: youtubeLink,
            experienceLevel: experienceLevel,
            portfolioLinks: portfolioLinks,
            jobApplications: jobApplications,
            approvedApplications: approvedApplications,
            planName: planName,
            isOwner: isOwner,
          ),
          SizedBox(height: 16.h),
          _WorksSection(user: userData),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _WorksSection extends StatelessWidget {
  final UserModel user;
  const _WorksSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user.profile;

    final roles = (profile?.roles ?? []).map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final content = m['content'] != null
          ? Map<String, dynamic>.from(m['content'] as Map)
          : <String, dynamic>{};
      final posterUrl =
          (content['poster'] ?? content['image'] ?? m['image'] ?? '')
              .toString();
      return {
        'id': m['id'] ?? 0,
        'title': (content['name'] ?? m['name'] ?? '').toString(),
        'role': (m['role'] ?? '').toString(),
        'contentType': (content['type'] ?? '').toString(),
        'contentId': content['id'] ?? 0,
        'url': posterUrl,
        'isVideo': false,
      };
    }).toList();

    final images = (profile?.images ?? [])
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final imageUrl = (m['image'] ?? '').toString();
          return {
            'title': (m['title'] ?? '').toString(),
            'role': (m['role'] ?? '').toString(),
            'url': imageUrl,
            'isVideo': false,
          };
        })
        .where((item) => (item['url'] as String).isNotEmpty)
        .toList();

    final videos = (profile?.videos ?? [])
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final videoUrl = (m['thumbnail'] ?? m['video'] ?? '').toString();
          return {
            'title': (m['title'] ?? '').toString(),
            'role': (m['role'] ?? '').toString(),
            'url': videoUrl,
            'isVideo': true,
          };
        })
        .where((item) => (item['url'] as String).isNotEmpty)
        .toList();

    final works = [
      ...roles,
      ...images,
      ...videos,
    ].where((e) => (e['url'] ?? '').toString().isNotEmpty).toList();

    if (works.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'common_my_works'.tr().isNotEmpty
                    ? 'common_my_works'.tr()
                    : 'My Works',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AllWorksScreen(user: user),
                    ),
                  );
                },
                child: Text(
                  'viewAll'.tr().isNotEmpty ? 'viewAll'.tr() : 'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: works.length,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            final w = works[index];
            return _WorkItem(
              image: w['url'] as String,
              title: (w['title'] as String).trim(),
              role: (w['role'] as String).trim().replaceAll('_', ' '),
              isVideo: w['isVideo'] as bool,
              contentType: w['contentType'] as String?,
            );
          },
        ),
      ],
    );
  }
}

class _WorkItem extends StatelessWidget {
  final String image;
  final String title;
  final String role;
  final bool isVideo;
  final String? contentType;

  const _WorkItem({
    required this.image,
    required this.title,
    required this.role,
    required this.isVideo,
    this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              CachedNetworkImage(
                imageUrl: image.startsWith('http')
                    ? image
                    : AppUrls.imageLink(image),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey[400],
                    size: 40.sp,
                  ),
                ),
              ),
              // Bottom frosted glass overlay for text
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _RoleBadge(role: role),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Video play icon
              if (isVideo)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              // Content type badge (top-right)
              if (contentType != null && contentType!.isNotEmpty)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          contentType == 'series'
                              ? Icons.tv_outlined
                              : Icons.movie_outlined,
                          color: Colors.white,
                          size: 11.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          contentType!.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
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

  void _showFullScreenImage(BuildContext context) {
    final imageUrl = image.startsWith('http')
        ? image
        : AppUrls.imageLink(image);

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  static const Map<String, _RoleStyle> _styles = {
    'lead_actor': _RoleStyle(AppColors.secondaryColor, Icons.star_rounded),
    'actress': _RoleStyle(AppColors.primaryColor, Icons.theater_comedy_rounded),
    'director': _RoleStyle(
      AppColors.primaryColor,
      Icons.movie_creation_rounded,
    ),
    'supporting_actor': _RoleStyle(
      AppColors.secondaryColor,
      Icons.person_outline_rounded,
    ),
    'supporting_actress': _RoleStyle(
      AppColors.primaryColor,
      Icons.person_outline_rounded,
    ),
    'writer': _RoleStyle(AppColors.primaryColor, Icons.edit_note_rounded),
    'producer': _RoleStyle(
      AppColors.secondaryColor,
      Icons.account_balance_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final key = role.replaceAll(' ', '_');
    final style =
        _styles[key] ??
        const _RoleStyle(AppColors.primaryColor, Icons.person_rounded);
    final displayRole = role.replaceAll('_', ' ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: style.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13.sp, color: style.color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              displayRole.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStyle {
  final Color color;
  final IconData icon;
  const _RoleStyle(this.color, this.icon);
}
