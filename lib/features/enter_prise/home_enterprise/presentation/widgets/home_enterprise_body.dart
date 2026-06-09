import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/extensions/translation_extension.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/widgets/performance_metric_card/performance_metric_card.dart';
import 'package:aflam/core/widgets/profile_header/profile_header_widget.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/core/widgets/workshop_card/workshop_card_widget.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/widgets/workshop/work_shop_details.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart'
    as enterprise;
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_section.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../data/model/performance_metric_model.dart';
import '../../../../../config/routes/routes.dart';
import '../cubit/home_enterprise_cubit.dart';
import '../cubit/home_enterprise_state.dart';
import 'enterprise_action_buttons.dart';
import '../../../../shared/talent_profile/presentation/screens/talent_profile_args.dart';

class HomeEnterpriseBody extends StatelessWidget {
  const HomeEnterpriseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeEnterpriseCubit, HomeEnterpriseState>(
      builder: (context, state) {
        // Don't show loading - load data in background for better UX
        // Show shimmer skeleton while loading
        if (state is HomeEnterpriseLoading || state is HomeEnterpriseInitial) {
          return _buildShimmerSkeleton(context);
        }

        if (state is HomeEnterpriseError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                ElevatedButton(
                  onPressed: () =>
                      context.read<HomeEnterpriseCubit>().refreshData(),
                  child: Text('common_retry'.trOrFallback('Retry')),
                ),
              ],
            ),
          );
        }

        if (state is HomeEnterpriseLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeEnterpriseCubit>().refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Upper Section Redesign
                  Container(
                    padding: EdgeInsets.only(top: 30.h, bottom: 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeTopBar(showChat: true),
                          20.height,
                          // Profile Header Card
                          Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.08,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: UserHelper.userNotifier,
                              builder: (context, user, _) {
                                return ProfileHeaderWidget(
                                  name: state.profile.name,
                                  profileImage: state.profile.profileImage,
                                  isVerified: state.profile.waterMark,
                                  rating: state.profile.rating,
                                  reviewsCount: state.profile.reviewsCount,
                                  isAvailable:
                                      user?.profile?.isAvailable ??
                                      state.profile.isAvailable,
                                  images: state.profile.images,
                                );
                              },
                            ),
                          ),
                          16.height,
                          // Performance Metrics
                          _PerformanceMetrics(metrics: state.metrics),
                          16.height,
                          // Action Buttons
                          EnterpriseActionButtons(),
                        ],
                      ),
                    ),
                  ),
                  // Scrollable Content Section merged here
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 16.h,
                      bottom: 100
                          .h, // Increased padding to ensure last item is fully visible
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSection(
                          title: 'home_trending'.trOrFallback('Trending Movie'),
                          onSeeMoreTap: () {
                            context.pushNamed(Routes.trending);
                          },
                          child: SizedBox(
                            height: 126.h,
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
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 12.w),
                                    itemBuilder: (context, index) {
                                      final movie = state.trending[index];
                                      return SizedBox(
                                        width: 105.w,
                                        child: _EnterpriseTrendingMovieCard(
                                          movie: movie,
                                          onTap: () {
                                            final isSeries =
                                                movie.artWorkType == 'series';
                                            final item = MovieOrSeriesItem(
                                              id: movie.id,
                                              name: isSeries
                                                  ? null
                                                  : movie.name,
                                              title: isSeries
                                                  ? movie.name
                                                  : null,
                                              about: movie.about,
                                              price: movie.price,
                                              coverImage: movie.coverImage,
                                              coverPhoto: movie.coverImage,
                                              actors: movie.actors,
                                              trailer: movie.trailer,
                                              viewsCount: movie.viewsCount,
                                              category: movie.category,
                                              isReady: movie.isReady,
                                              adminApproved:
                                                  movie.adminApproved,
                                              video: movie.video,
                                              isFavorite:
                                                  movie.isFavorite ?? false,
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
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        16.height,
                        // New Workshops Section (using state.workshops from API)
                        HomeSection(
                          title: 'home_new_workshops'.trOrFallback(
                            'New Workshops',
                          ),
                          onSeeMoreTap: () {
                            // Navigate to workshops list screen
                            // Pass null to let the screen fetch all workshops from API
                            context.pushNamed(
                              Routes.findWorkshops,
                              extra: null,
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
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.workshops.length,
                                    itemBuilder: (context, index) {
                                      final workshop = state.workshops[index];
                                      final workshopId = int.tryParse(
                                        workshop.id,
                                      );
                                      return WorkshopCardWidget(
                                        title: workshop.title,
                                        instructor: workshop.instructor,
                                        date: workshop.date,
                                        imageUrl: workshop.imageUrl,
                                        onTap: () {
                                          if (workshopId != null) {
                                            // Navigate to workshop details
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => BlocProvider(
                                                  create: (context) =>
                                                      getIt<WorkshopCubit>(),
                                                  child: WorkShopDetails(
                                                    workshopId: workshopId,
                                                    mode: WorkShopDetailsMode
                                                        .userApply,
                                                    showAppBar: true,
                                                    onBack: () => Navigator.of(
                                                      context,
                                                    ).pop(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                        24.height,
                        HomeSection(
                          title: "home_find_talent".trOrFallback("Find Talent"),
                          onSeeMoreTap: () {
                            context.pushNamed(
                              Routes.findTalent,
                              extra: state.talents,
                            );
                          },
                          child: SizedBox(
                            height: 168.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.talents.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
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
                        // Find Student Section
                        HomeSection(
                          title: 'home_find_student'.trOrFallback(
                            'Find Student',
                          ),
                          onSeeMoreTap: () {
                            context.pushNamed(
                              Routes.findStudent,
                              extra: state.students,
                            );
                          },
                          child: SizedBox(
                            height: 115.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.students.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
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
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context) {
    return Column(
      children: [
        // Updated Upper Section Shimmer
        Container(
          padding: EdgeInsets.only(top: 30.h, bottom: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeTopBar(showChat: true),
                20.height,
                // Profile Header Card Shimmer
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Profile Image Shimmer
                          CustomShimmerWidget(
                            width: 78.r,
                            height: 78.r,
                            shape: BoxShape.circle,
                          ),
                          16.width,
                          // Name and Info Shimmer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomShimmerWidget(
                                  width: double.infinity,
                                  height: 22.h,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                6.height,
                                CustomShimmerWidget(
                                  width: 120.w,
                                  height: 18.h,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                6.height,
                                CustomShimmerWidget(
                                  width: 100.w,
                                  height: 14.h,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                16.height,
                // Performance Metrics Shimmer
                Row(
                  children: List.generate(
                    2,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 1 ? 10.w : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            children: [
                              CustomShimmerWidget(
                                width: double.infinity,
                                height: 16.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              2.height,
                              CustomShimmerWidget(
                                width: 50.w,
                                height: 24.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                16.height,
                // Action Buttons Shimmer
                Row(
                  children: [
                    Expanded(
                      child: CustomShimmerWidget(
                        width: double.infinity,
                        height: 45.h,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: CustomShimmerWidget(
                        width: double.infinity,
                        height: 45.h,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: CustomShimmerWidget(
                        width: double.infinity,
                        height: 45.h,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Scrollable Content Shimmer
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title Shimmer
                CustomShimmerWidget(
                  width: 120.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                12.height,
                // Horizontal List Shimmer
                SizedBox(
                  height: 150.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => 12.width,
                    itemBuilder: (_, __) => CustomShimmerWidget(
                      width: 105.w,
                      height: 150.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                24.height,
                // Another Section
                CustomShimmerWidget(
                  width: 120.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                12.height,
                SizedBox(
                  height: 200.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => 12.width,
                    itemBuilder: (_, __) => CustomShimmerWidget(
                      width: 180.w,
                      height: 200.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceMetrics extends StatelessWidget {
  final List<PerformanceMetricModel> metrics;

  const _PerformanceMetrics({required this.metrics});

  @override
  Widget build(BuildContext context) {
    // Separate views/bookings from topWork
    final standardMetrics = metrics.where((m) => m.type != 'topWork').toList();
    final topWorkMetrics = metrics.where((m) => m.type == 'topWork').toList();

    return Column(
      children: [
        // Views and Bookings in a row with modern styling
        if (standardMetrics.isNotEmpty)
          Row(
            children: standardMetrics
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: entry.key < standardMetrics.length - 1 ? 10.w : 0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: PerformanceMetricCard(
                          type: entry.value.type,
                          label: entry.value.label.tr(),
                          value: entry.value.value,
                          topWorkTitle: entry.value.topWorkTitle,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        // Top Work in a separate row (full width) with modern styling
        if (topWorkMetrics.isNotEmpty) ...[
          12.height,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: double.infinity,
            child: PerformanceMetricCard(
              type: topWorkMetrics.first.type,
              label: topWorkMetrics.first.label.tr(),
              value: topWorkMetrics.first.value,
              topWorkTitle: topWorkMetrics.first.topWorkTitle,
            ),
          ),
        ],
      ],
    );
  }
}

class _TalentCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  final bool isVerified;
  final VoidCallback onTap;

  const _TalentCard({
    required this.name,
    required this.role,
    this.imageUrl,
    this.isVerified = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border(
            top: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
            right: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
            bottom: BorderSide.none,
            left: BorderSide(color: const Color(0xFFD1D1D1), width: 1.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            12.height,
            // Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified) ...[
                  4.width,
                  Icon(
                    Icons.verified,
                    color: const Color(0xFF2F80ED),
                    size: 14.sp,
                  ),
                ],
              ],
            ),
            4.height,
            // Role
            if (role.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lightBGColor,
      child: Icon(Icons.person, size: 30.sp, color: AppColors.greyText),
    );
  }
}

// New Vertical Design - Avatar Top with Content Below
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

// Brand new design 2 - Modern Glass Effect Card with Diagonal Cut
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

class _EnterpriseTrendingMovieCard extends StatelessWidget {
  final enterprise.MovieModel movie;
  final VoidCallback onTap;

  const _EnterpriseTrendingMovieCard({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105.w,
        height: 126.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: CustomCachedNetworkImage(
            url: movie.coverImage ?? '',
            fit: BoxFit.cover,
            serverImage: true,
          ),
        ),
      ),
    );
  }
}
