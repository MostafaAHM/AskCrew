import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/extensions/translation_extension.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_section.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/widgets/workshop/work_shop_details.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../cubit/home_student_cubit.dart';
import '../cubit/home_student_state.dart';
import 'student_workshop_card.dart';
import '../../../../shared/talent_profile/presentation/screens/talent_profile_args.dart';

class StudentScrollableContent extends StatelessWidget {
  const StudentScrollableContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStudentCubit, HomeStudentState>(
      builder: (context, state) {
        if (state is HomeStudentLoaded) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 16.h,
              bottom: 100.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // New Workshops Section (using state.workshops)
                HomeSection(
                  title: 'home_new_workshops'.trOrFallback('New Workshops'),
                  onSeeMoreTap: () {
                    // Navigate to workshops list screen
                    context.pushNamed(
                      Routes.findWorkshops,
                      extra: state.workshops,
                    );
                  },
                  child: SizedBox(
                    height: 200.h,
                    child: state.workshops.isEmpty
                        ? Center(
                            child: Text(
                              'common_no_workshops_found'.trOrFallback(
                                'No workshops found',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.workshops.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final workshop = state.workshops[index];
                              final formattedDate = DateFormat(
                                'd MMM',
                              ).format(workshop.startDate);
                              final instructor =
                                  workshop.createdByFullname ?? '—';

                              return StudentWorkshopCard(
                                title: workshop.name,
                                date: formattedDate,
                                instructor:
                                    '${'common_by'.trOrFallback('BY')} $instructor',
                                imageUrl: workshop.coverImage ?? '',
                                onTap: () {
                                  // Navigate to workshop details
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (context) =>
                                            getIt<WorkshopCubit>(),
                                        child: WorkShopDetails(
                                          workshopId: workshop.id,
                                          mode: WorkShopDetailsMode.userApply,
                                          showAppBar: true,
                                          onBack: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
                16.height,
                HomeSection(
                  title: 'home_trending'.trOrFallback('Trending Movie'),
                  onSeeMoreTap: () {
                    context.pushNamed(Routes.trending);
                  },
                  child: SizedBox(
                    height: 220.h,
                    child: state.trending.isEmpty
                        ? Center(
                            child: Text(
                              'common_no_content_found'.trOrFallback(
                                'No content found',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.trending.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final movie = state.trending[index];
                              return _TrendingMovieCard(
                                movie: movie,
                                onTap: () {
                                  final isSeries =
                                      movie.artWorkType == 'series';
                                  final item = MovieOrSeriesItem(
                                    id: movie.id,
                                    name: isSeries ? null : movie.name,
                                    title: isSeries ? movie.name : null,
                                    about: movie.about,
                                    price: movie.price,
                                    coverImage: movie.coverImage,
                                    coverPhoto: movie.coverImage,
                                    actors: movie.actors,
                                    trailer: movie.trailer,
                                    viewsCount: movie.viewsCount,
                                    category: movie.category,
                                    isReady: movie.isReady,
                                    adminApproved: movie.adminApproved,
                                    video: movie.video,
                                    isFavorite: movie.isFavorite ?? false,
                                    isRated: movie.isRated ?? false,
                                    isPaid: movie.isPaid,
                                    userRating: movie.userRating,
                                    ratingMean: movie.ratingMean,
                                    ratingCount: movie.ratingCount,
                                    artWorkType: movie.artWorkType,
                                    createdAt: movie.createdAt,
                                    updatedAt: movie.createdAt,
                                  );
                                  context.pushNamed(
                                    Routes.movieDetails,
                                    extra: item,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
                24.height,
                // Show Talents Section (using state.talents)
                HomeSection(
                  title: 'home_show_talents'.trOrFallback('Show Talents'),
                  onSeeMoreTap: () {
                    context.pushNamed(Routes.findTalent, extra: state.talents);
                  },
                  child: SizedBox(
                    height: 168.h,
                    child: state.talents.isEmpty
                        ? Center(
                            child: Text(
                              'common_no_talents_found'.trOrFallback(
                                'No talents found',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.talents.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final talent = state.talents[index];
                              return _EnterpriseTalentCard(
                                name: talent.name,
                                role: talent.role,
                                imageUrl: talent.imageUrl,
                                isVerified: talent.waterMark,
                                rating: talent.rating,
                                specialization: talent.specialization,
                                onTap: () {
                                  final userId = int.tryParse(talent.id);
                                  if (userId != null) {
                                    context.pushNamed(
                                      Routes.talentProfile,
                                      extra: TalentProfileArgs(id: talent.id),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ),
                24.height,
                // Find Student Section (using state.students)
                HomeSection(
                  title: 'home_find_student'.trOrFallback('Find Student'),
                  onSeeMoreTap: () {
                    context.pushNamed(
                      Routes.findStudent,
                      extra: state.students,
                    );
                  },
                  child: SizedBox(
                    height: 115.h,
                    child: state.students.isEmpty
                        ? Center(
                            child: Text(
                              'common_no_students_found'.trOrFallback(
                                'No students found',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.students.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final student = state.students[index];
                              return _EnterpriseStudentCard(
                                name: student.name,
                                role: student.role,
                                imageUrl: student.imageUrl,
                                isVerified: student.waterMark,
                                rating: student.rating,
                                specialization: student.specialization,
                                onTap: () {
                                  final userId = int.tryParse(student.id);
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
                40.height,
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _TrendingMovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const _TrendingMovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CustomCachedNetworkImage(
                height: 150.h,
                width: 110.w,
                fit: BoxFit.cover,
                url: movie.coverImage ?? '',
                serverImage: true,
              ),
            ),
            8.height,
            Row(
              children: [
                Expanded(
                  child: Text(
                    movie.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (movie.ratingMean != null) ...[
                  6.width,
                  Icon(Icons.star, color: Colors.orange, size: 16.sp),
                  4.width,
                  Text(
                    movie.ratingMean!.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// New Vertical Design - Avatar Top with Content Below (from Enterprise)
class _EnterpriseTalentCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final bool isVerified;
  final double rating;
  final String specialization;
  final VoidCallback onTap;

  const _EnterpriseTalentCard({
    required this.name,
    required this.role,
    this.imageUrl,
    this.isVerified = false,
    this.rating = 0.0,
    this.specialization = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 168.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient top background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.18),
                      AppColors.secondaryColor.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with verified badge
                  Stack(
                    children: [
                      Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? CustomCachedNetworkImage(
                                  url: imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 26.sp,
                                  color: AppColors.primaryColor.withOpacity(
                                    0.45,
                                  ),
                                ),
                        ),
                      ),
                      if (isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2.5.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondaryColor,
                                  AppColors.primaryColor,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.25,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 10.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.5.h),
                  // Rating stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.secondaryColor,
                          size: 9.5.sp,
                        );
                      }),
                      SizedBox(width: 4.w),
                      if (rating > 0)
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.5.h),
                  // Role tag
                  if (role.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Specialization
                  if (specialization.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 3.h),
                      child: Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 7.5.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Brand new design 2 - Modern Glass Effect Card with Diagonal Cut (from Enterprise)
class _EnterpriseStudentCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final bool isVerified;
  final double rating;
  final String specialization;
  final VoidCallback onTap;

  const _EnterpriseStudentCard({
    required this.name,
    required this.role,
    this.imageUrl,
    this.isVerified = false,
    this.rating = 0.0,
    this.specialization = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        height: 115.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Diagonal accent corner
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                size: Size(60.w, 60.h),
                painter: DiagonalPainter(),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // Image Section
                  Container(
                    width: 65.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.secondaryColor.withOpacity(0.15),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: imageUrl != null && imageUrl!.isNotEmpty
                                  ? CustomCachedNetworkImage(
                                      url: imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.school,
                                      size: 24.sp,
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.5),
                                    ),
                            ),
                          ),
                        ),
                        if (isVerified)
                          Positioned(
                            top: 2.h,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondaryColor,
                                    AppColors.primaryColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  10.width,
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.lightTText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        // Role badge
                        if (role.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.secondaryColor.withOpacity(
                                  0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ),
                        5.height,
                        // Stars
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.secondaryColor,
                                size: 10.sp,
                              );
                            }),
                            5.width,
                            if (rating > 0)
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                          ],
                        ),
                        4.height,
                        // Specialization
                        if (specialization.isNotEmpty)
                          Text(
                            specialization,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for diagonal corner
class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
