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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.verticalSpace,
                        HomeTopBar(showChat: true),
                        16.height,
                        Container(
                          padding: EdgeInsets.all(16.w),
                          child: ValueListenableBuilder(
                            valueListenable: UserHelper.userNotifier,
                            builder: (context, user, _) {
                              return ProfileHeaderWidget(
                                name: state.profile.name,
                                profession: state.profile.profession,
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
                        _PerformanceMetrics(metrics: state.metrics),
                        16.height,
                        EnterpriseActionButtons(),
                      ],
                    ),
                  ),
                  16.height,
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
                          title: 'home_find_talent'.trOrFallback('Find Talent'),
                          onSeeMoreTap: () {
                            context.pushNamed(
                              Routes.findTalent,
                              extra: state.talents,
                            );
                          },
                          child: SizedBox(
                            height: 140.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.talents.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
                              itemBuilder: (context, index) {
                                final talent = state.talents[index];
                                return _TalentCard(
                                  name: talent.name,
                                  role: talent.role,
                                  specialization: talent.specialization,
                                  imageUrl: talent.imageUrl,
                                  isVerified: talent.waterMark,
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
                            height: 140.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.students.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
                              itemBuilder: (context, index) {
                                final student = state.students[index];
                                return _TalentCard(
                                  name: student.name,
                                  role: student.role,
                                  specialization: student.specialization,
                                  imageUrl: student.imageUrl,
                                  isVerified: student.waterMark,
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
        // Fixed Header Section with Shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.verticalSpace,
              HomeTopBar(showChat: true),
              16.height,
              // Profile Header Shimmer
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile Image Shimmer
                        CustomShimmerWidget(
                          width: 60.r,
                          height: 60.r,
                          shape: BoxShape.circle,
                        ),
                        12.width,
                        // Name and Profession Shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomShimmerWidget(
                                width: double.infinity,
                                height: 20.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              8.height,
                              CustomShimmerWidget(
                                width: 150.w,
                                height: 16.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    // Rating Shimmer
                    Row(
                      children: [
                        CustomShimmerWidget(
                          width: 100.w,
                          height: 20.h,
                          borderRadius: BorderRadius.circular(8.r),
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
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          CustomShimmerWidget(
                            width: double.infinity,
                            height: 16.h,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          8.height,
                          CustomShimmerWidget(
                            width: 40.w,
                            height: 20.h,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ],
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
                      height: 50.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: CustomShimmerWidget(
                      width: double.infinity,
                      height: 50.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        16.height,
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
        // Views and Bookings in a row
        if (standardMetrics.isNotEmpty)
          Row(
            children: standardMetrics
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: entry.key < standardMetrics.length - 1 ? 12.w : 0,
                      ),
                      child: PerformanceMetricCard(
                        type: entry.value.type,
                        label: entry.value.label.tr(),
                        value: entry.value.value,
                        topWorkTitle: entry.value.topWorkTitle,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        // Top Work in a separate row (full width)
        if (topWorkMetrics.isNotEmpty) ...[
          12.height,
          SizedBox(
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
  final String specialization;
  final String? imageUrl;
  final bool isVerified;
  final VoidCallback onTap;

  const _TalentCard({
    required this.name,
    required this.role,
    this.specialization = '',
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
            // Role & Specialization
            if (role.isNotEmpty) ...[
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
              2.height,
            ],
            Text(
              specialization,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
