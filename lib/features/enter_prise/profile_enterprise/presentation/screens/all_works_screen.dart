import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'dart:ui';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllWorksScreen extends StatelessWidget {
  final UserModel user;

  const AllWorksScreen({super.key, required this.user});

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
        'title': (content['name'] ?? m['name'] ?? '').toString(),
        'role': (m['role'] ?? '').toString(),
        'contentType': (content['type'] ?? '').toString(),
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        title: Text(
          'My Works'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
      body: works.isEmpty
          ? Center(
              child: Text(
                'noWorksYet'.tr().isNotEmpty
                    ? 'noWorksYet'.tr()
                    : 'No works yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: GridView.builder(
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
                  return _AllWorkItem(
                    image: w['url'] as String,
                    title: (w['title'] as String).trim(),
                    role: (w['role'] as String).trim().replaceAll('_', ' '),
                    isVideo: w['isVideo'] as bool,
                    contentType: w['contentType'] as String?,
                  );
                },
              ),
            ),
    );
  }
}

class _AllWorkItem extends StatelessWidget {
  final String image;
  final String title;
  final String role;
  final bool isVideo;
  final String? contentType;

  const _AllWorkItem({
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
              CachedNetworkImage(
                imageUrl: image.startsWith('http')
                    ? image
                    : AppUrls.imageLink(image),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: AnimatedLoading(),
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
              // Bottom frosted glass overlay
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
                  child: AnimatedLoading(color: Colors.white),
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
