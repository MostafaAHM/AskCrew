import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_trending_repository.dart';
import 'package:aflam/features/shared/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import '../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';

import '../../../../../config/routes/routes.dart';

import '../../data/model/movies_with_series_model.dart';
import '../../presentation/cubit/movies_with_series_cubit.dart';
import '../../presentation/cubit/movies_with_series_state.dart';
import 'home_top_bar.dart';
import 'category_tabs.dart';
import 'banner_carousel.dart';
import 'home_section.dart';
import 'continue_watching_card.dart';
import 'movie_or_series_card.dart';
import '../../../continue_watching/presentation/cubit/continue_watching_cubit.dart';
import '../../../continue_watching/presentation/cubit/continue_watching_state.dart';
import '../cubit/banner_cubit.dart';

class HomeBodyViewer extends StatefulWidget {
  const HomeBodyViewer({super.key});

  @override
  State<HomeBodyViewer> createState() => _HomeBodyViewerState();
}

class _HomeBodyViewerState extends State<HomeBodyViewer> {
  final GetTrendingRepository _trendingRepository =
      getIt<GetTrendingRepository>();
  List<MovieOrSeriesItem> _trending = [];
  bool _isLoadingTrending = true;

  int? _selectedCategoryId;
  late final MoviesWithSeriesCubit _moviesWithSeriesCubit;

  @override
  void initState() {
    super.initState();
    _moviesWithSeriesCubit = getIt<MoviesWithSeriesCubit>();
    _loadTrending();
    // Load initial data without category filter
    _moviesWithSeriesCubit.getMoviesWithSeries();
    context.read<ContinueWatchingCubit>().loadContinueWatching();

    // Listen to user changes (e.g. after payment) to refresh data
    UserHelper.userNotifier.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    if (mounted) {
      _onRefresh();
    }
  }

  @override
  void dispose() {
    UserHelper.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    // Reload movies with series with category filter
    _moviesWithSeriesCubit.getMoviesWithSeries(categoryId: categoryId);
  }

  /// Refresh all data on the screen
  Future<void> _onRefresh() async {
    final futures = <Future>[];

    futures.add(_loadTrending());
    futures.add(
      _moviesWithSeriesCubit.getMoviesWithSeries(
        categoryId: _selectedCategoryId,
      ),
    );

    if (mounted) {
      futures.add(context.read<BannerCubit>().getBanners());
      futures.add(context.read<ContinueWatchingCubit>().loadContinueWatching());
      // Refresh categories (available via generic provider in home screen)
      futures.add(context.read<CategoriesCubit>().getCategories());
    }

    await Future.wait(futures);
  }

  /// Convert MovieModel to MovieOrSeriesItem
  MovieOrSeriesItem _convertMovieModelToItem(MovieModel movie) {
    final isSeries = movie.artWorkType == 'series';
    return MovieOrSeriesItem(
      id: movie.id,
      name: isSeries ? null : movie.name,
      title: isSeries
          ? movie.name
          : null, // API returns name for both, we use it as title for series
      about: movie.about,
      price: movie.price,
      coverImage: movie.coverImage,
      coverPhoto: movie.coverImage, // Use same image for both
      actors: movie.actors,
      trailer: movie.trailer,
      viewsCount: movie.viewsCount,
      category: movie.category,
      isReady: movie.isReady,
      adminApproved: movie.adminApproved,
      video: movie.video,
      isFavorite: movie.isFavorite ?? false,
      isRated: movie.isRated ?? false,
      isPaid: movie.isPaid, // Use isPaid from MovieModel
      userRating: movie.userRating,
      ratingMean: movie.ratingMean,
      ratingCount: movie.ratingCount,
      artWorkType: movie.artWorkType,
      createdAt: movie.createdAt,
      updatedAt: movie.createdAt, // Use createdAt as fallback
    );
  }

  Future<void> _loadTrending() async {
    final result = await _trendingRepository.getTrending();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoadingTrending = false;
          });
        }
      },
      (response) {
        if (mounted) {
          setState(() {
            _trending = response.results
                .map((movie) => _convertMovieModelToItem(movie))
                .toList();
            _isLoadingTrending = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              4.height,
              const HomeTopBar(showProfileStatus: true),
              10.height,
              CategoryTabs(onCategorySelected: _onCategorySelected),
              10.height,
              const BannerCarousel(),
              10.height,
            ],
          ),
        ),
        // Scrollable Content Section
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensure it scrolls even if empty to allow refresh
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.height,
                  BlocBuilder<ContinueWatchingCubit, ContinueWatchingState>(
                    builder: (context, state) {
                      if (state is ContinueWatchingSuccess &&
                          state.items.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeSection(
                              title: AppStrings.continueWatching.tr(),
                              onSeeMoreTap: null, // No see more page requested
                              child: SizedBox(
                                height: 170.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.items.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 12.w),
                                  itemBuilder: (context, index) {
                                    final item = state.items[index];
                                    return ContinueWatchingCard(
                                      item: item,
                                      onTap: () async {
                                        if (item.contentData != null) {
                                          await context.pushNamed(
                                            Routes.movieDetails,
                                            extra: item.contentData,
                                          );
                                          // Refresh when returning from video
                                          if (context.mounted) {
                                            context
                                                .read<ContinueWatchingCubit>()
                                                .loadContinueWatching(
                                                  isRefresh: true,
                                                );
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            24.height,
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  16.height,
                  BlocProvider.value(
                    value: _moviesWithSeriesCubit,
                    child:
                        BlocBuilder<
                          MoviesWithSeriesCubit,
                          MoviesWithSeriesState
                        >(
                          builder: (context, state) {
                            if (state is MoviesWithSeriesLoading) {
                              return HomeSection(
                                title: AppStrings.seriesAndMovies.tr(),
                                onSeeMoreTap: () {
                                  context.pushNamed(Routes.seriesAndMovies);
                                },
                                child: _buildSkeletonMoviesList(215.h),
                              );
                            }

                            if (state is MoviesWithSeriesError) {
                              return HomeSection(
                                title: AppStrings.seriesAndMovies.tr(),
                                onSeeMoreTap: () {
                                  context.pushNamed(Routes.seriesAndMovies);
                                },
                                child: SizedBox(
                                  height: 200.h,
                                  child: Center(
                                    child: Text(
                                      state.message,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is MoviesWithSeriesLoaded) {
                              final items = state.response.results;
                              if (items.isEmpty) {
                                return HomeSection(
                                  title: AppStrings.seriesAndMovies.tr(),
                                  onSeeMoreTap: () {
                                    context.pushNamed(Routes.seriesAndMovies);
                                  },
                                  child: SizedBox(
                                    height: 200.h,
                                    child: Center(
                                      child: Text(
                                        AppStrings.itemsNotFound.tr(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return HomeSection(
                                title: AppStrings.seriesAndMovies.tr(),
                                onSeeMoreTap: () {
                                  context.pushNamed(Routes.seriesAndMovies);
                                },
                                child: SizedBox(
                                  height: 215.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 12.w),
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return MovieOrSeriesCard(
                                        item: item,
                                        onTap: () {
                                          // Navigate to movie details screen
                                          context.pushNamed(
                                            Routes.movieDetails,
                                            extra: item,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                  ),
                  16.height,
                  HomeSection(
                    title: AppStrings.homeTrending.tr(),
                    onSeeMoreTap: () {
                      context.pushNamed(Routes.trending);
                    },
                    child: SizedBox(
                      height: 235.h,
                      child: _isLoadingTrending
                          ? _buildSkeletonMoviesList(235.h)
                          : _trending.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.itemsNotFound.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _trending.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 12.w),
                              itemBuilder: (context, index) {
                                final item = _trending[index];
                                return MovieOrSeriesCard(
                                  item: item,
                                  onTap: () {
                                    // Navigate to movie details screen
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
                ],
              ),
            ),
          ),
        ),
        ],
      );
    }

  Widget _buildSkeletonMoviesList(double height) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomShimmerWidget(
                width: 110.w,
                height: 165.h,
                borderRadius: BorderRadius.circular(16.r),
              ),
              10.height,
              CustomShimmerWidget(
                width: 80.w,
                height: 14.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          );
        },
      ),
    );
  }
}
