import 'dart:ui';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:aflam/features/chat/presentation/screens/chat_screen.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/core/helpers/authorization_helper.dart';
import 'package:aflam/features/shared/plans/presentation/screens/plans_screen.dart';

class YourProfileScreen extends StatefulWidget {
  final UserModel? user;

  const YourProfileScreen({super.key, this.user});

  @override
  State<YourProfileScreen> createState() => _YourProfileScreenState();
}

class _YourProfileScreenState extends State<YourProfileScreen> {
  bool get _isMyProfile => widget.user == null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = getIt<ProfileCubit>();
            if (widget.user != null) {
              cubit.seedProfile(widget.user!, isOwner: true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                cubit.getUserProfile(widget.user!.id);
              });
            } else {
              cubit.getMyProfile();
            }
            return cubit;
          },
        ),
        BlocProvider(create: (context) => getIt<ChatCubit>()),
      ],
      child: BlocListener<ChatCubit, ChatState>(
        listener: (context, chatState) {
          if (chatState.status == ChatStatus.success &&
              chatState.selectedRoom != null) {
            final userData = widget.user;
            if (userData == null) return;

            final room = chatState.selectedRoom!;
            final chatCubit = context.read<ChatCubit>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: chatCubit,
                  child: ChatScreen(
                    roomId: room.id,
                    roomName: userData.fullname,
                    otherUserImage: userData.profilePhoto,
                    specification: userData.profile?.specification,
                    otherUser: userData,
                  ),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          backgroundColor: const Color(0xFFFAF9F6),
          body: SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final cubit = context.read<ProfileCubit>();
                UserModel? userToDisplay;

                if (widget.user != null) {
                  if (state is ProfileLoaded) {
                    userToDisplay = state.user;
                  } else {
                    userToDisplay = widget.user;
                  }
                } else {
                  if (state is ProfileLoaded) {
                    userToDisplay = state.user;
                  } else if (state is ProfileLoading &&
                      state.previousUser != null) {
                    userToDisplay = state.previousUser;
                  } else if (cubit.currentUser != null) {
                    userToDisplay = cubit.currentUser;
                  }
                }

                if (userToDisplay != null) {
                  final user = userToDisplay;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              12.verticalSpace,
                              _ProfileInfo(
                                user: user,
                                isMyProfile: _isMyProfile,
                                onPrimaryActionTap: () async {
                                  if (_isMyProfile) {
                                    final result = await context.pushNamed(
                                      Routes.editEnterpriseProfile,
                                    );
                                    if (result == true && context.mounted) {
                                      context
                                          .read<ProfileCubit>()
                                          .getMyProfile();
                                    }
                                    return;
                                  }
                                  final other = widget.user;
                                  if (other == null) return;
                                  // context.read<ChatCubit>().createChatRoom(other.id);
                                },
                                onWithdrawTap: () {
                                  context.pushNamed(Routes.recentTransactions);
                                },
                              ),
                              12.verticalSpace,
                              12.verticalSpace,
                              _StatsRow(user: user),
                              12.verticalSpace,
                              _AboutSection(user: user),
                              10.verticalSpace,
                              _DetailsSection(
                                user: user,
                                isMyProfile: _isMyProfile,
                              ),
                              12.verticalSpace,
                              _WorksSection(user: user),
                              24.verticalSpace,
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is ProfileError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        16.verticalSpace,
                        ElevatedButton(
                          onPressed: () {
                            if (widget.user != null) {
                              context.read<ProfileCubit>().getUserProfile(
                                widget.user!.id,
                              );
                            } else {
                              context.read<ProfileCubit>().getMyProfile();
                            }
                          },
                          child: Text('common_retry'.tr()),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatefulWidget {
  final UserModel user;
  final bool isMyProfile;
  final VoidCallback onPrimaryActionTap;
  final VoidCallback onWithdrawTap;

  const _ProfileInfo({
    required this.user,
    required this.isMyProfile,
    required this.onPrimaryActionTap,
    required this.onWithdrawTap,
  });

  @override
  State<_ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<_ProfileInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _withdrawButton() {
    return InkWell(
      onTap: widget.onWithdrawTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    );
  }

  Widget _primaryIconButton() {
    final icon = widget.isMyProfile ? Icons.edit : Icons.chat_bubble_outline;
    return InkWell(
      onTap: widget.onPrimaryActionTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _profileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            image:
                (widget.user.profilePhoto != null &&
                    widget.user.profilePhoto!.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(widget.user.profilePhoto!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child:
              (widget.user.profilePhoto == null ||
                  widget.user.profilePhoto!.isEmpty)
              ? Icon(Icons.person, size: 54.sp, color: Colors.grey.shade500)
              : null,
        ),
        Positioned(right: 4.w, bottom: 4.h, child: _primaryIconButton()),
      ],
    );
  }

  Widget _starsRow() {
    final rating = widget.user.ratingMean ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: Colors.orange, size: 17.sp);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: Colors.orange, size: 17.sp);
          } else {
            return Icon(Icons.star_border, color: Colors.orange, size: 17.sp);
          }
        }).expand((icon) => [icon, 2.horizontalSpace]).toList()..removeLast(),
        8.horizontalSpace,
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = (widget.user.ratingMean ?? 0) > 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Stack(
              children: [
                Center(child: _profileImage()),
                if (widget.isMyProfile)
                  Positioned(top: 0, right: 0, child: _withdrawButton()),
              ],
            ),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.fullname,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (widget.user.waterMark) ...[
                  6.horizontalSpace,
                  Icon(Icons.verified, color: Colors.blue, size: 20.sp),
                ],
              ],
            ),
            if (hasRating) ...[
              6.verticalSpace,
              _starsRow(),
              if ((widget.user.ratingCount ?? 0) > 0) ...[
                3.verticalSpace,
                Text(
                  '(${widget.user.ratingCount} reviews)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
            if (widget.user.profile?.specification != null &&
                widget.user.profile!.specification!.isNotEmpty) ...[
              6.verticalSpace,
              Text(
                widget.user.profile!.specification!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user.profile;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: "Views".tr(),
            value: (profile?.views ?? 0).toString(),
            icon: Icons.visibility_outlined,
            color: Colors.blue,
          ),
          _StatItem(
            label: "Bookings".tr(),
            value: (profile?.totalBookings ?? 0).toString(),
            icon: Icons.event_available_outlined,
            color: Colors.green,
          ),
          _StatItem(
            label: "Wallet".tr(),
            value: user.wallet,
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        8.verticalSpace,
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        4.verticalSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final UserModel user;
  const _AboutSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final personalInfo = user.personalInfo?.toString() ?? '';
    if (personalInfo.trim().isEmpty) return const SizedBox.shrink();

    final isProducer = AuthorizationHelper.isProducer();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF5F0), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFFFE0D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE0D0).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProducer ? Icons.business_outlined : Icons.person_outline,
                color: const Color(0xFF5D2E46),
                size: 20.sp,
              ),
              8.horizontalSpace,
              Text(
                isProducer ? 'About Company'.tr() : 'About'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5D2E46),
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            personalInfo,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final UserModel user;
  final bool isMyProfile;
  const _DetailsSection({required this.user, required this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    final profile = user.profile;
    final details = <Widget>[];

    if (profile?.city != null && profile!.city!.isNotEmpty) {
      final country = (profile.country ?? '').trim();
      final city = profile.city!.trim();
      details.add(
        _DetailItem(
          icon: Icons.location_on_outlined,
          text: country.isEmpty ? city : '$city, $country',
        ),
      );
    } else if (profile?.country != null && profile!.country!.isNotEmpty) {
      details.add(
        _DetailItem(icon: Icons.location_on_outlined, text: profile.country!),
      );
    }

    if (profile?.experience != null && profile!.experience!.isNotEmpty) {
      details.add(
        _DetailItem(
          icon: FontAwesomeIcons.graduationCap,
          text: profile.experience!,
        ),
      );
    }

    String? planName = profile?.plan?['tier']?.toString();
    if (planName == null || planName.isEmpty) {
      planName = profile?.paymentPlan;
    }

    if (planName != null && planName.isNotEmpty) {
      planName = planName[0].toUpperCase() + planName.substring(1);
    }

    if (planName != null && planName.isNotEmpty) {
      details.add(
        _DetailItem(
          icon: Icons.star_outline,
          text: 'Plan: $planName',
          trailing: isMyProfile
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
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Upgrade'.tr(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < details.length; i++) ...[
            details[i],
            if (i < details.length - 1)
              Divider(height: 1, color: Colors.grey.shade300),
          ],
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _DetailItem({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22.sp),
          12.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
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
                'My Works'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed(Routes.allWorks, extra: user),
                child: Text(
                  'View all'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
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
