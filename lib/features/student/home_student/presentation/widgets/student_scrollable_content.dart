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
import '../cubit/home_student_cubit.dart';
import '../cubit/home_student_state.dart';
import 'student_talent_card.dart';
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
                    height: 140.h,
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
                              return StudentTalentCard(
                                name: talent.name,
                                role: talent.role,
                                imageUrl: talent.imageUrl,
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
                    height: 140.h,
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
                              return StudentTalentCard(
                                name: student.name,
                                role: student.role,
                                imageUrl: student.imageUrl,
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
