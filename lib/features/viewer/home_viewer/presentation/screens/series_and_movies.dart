import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/shared/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/category_tabs.dart';
import '../widgets/movie_or_series_card.dart';
import '../../presentation/cubit/movies_with_series_cubit.dart';
import '../../presentation/cubit/movies_with_series_state.dart';
import '../../data/model/movies_with_series_model.dart';
import 'package:aflam/core/helpers/user_helper.dart';

class SeriesAndMoviesScreen extends StatefulWidget {
  const SeriesAndMoviesScreen({super.key});

  @override
  State<SeriesAndMoviesScreen> createState() => _SeriesAndMoviesScreenState();
}

class _SeriesAndMoviesScreenState extends State<SeriesAndMoviesScreen> {
  late final MoviesWithSeriesCubit _moviesCubit;
  late final CategoriesCubit _categoriesCubit;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _moviesCubit = getIt<MoviesWithSeriesCubit>()..getMoviesWithSeries();
    _categoriesCubit = getIt<CategoriesCubit>()..getCategories();
    
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
    _selectedCategoryId = categoryId;
    _moviesCubit.getMoviesWithSeries(categoryId: categoryId);
  }

  Future<void> _onRefresh() async {
    // Refresh categories
    _categoriesCubit.getCategories();
    // Refresh content with current filter
    await _moviesCubit.getMoviesWithSeries(categoryId: _selectedCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _categoriesCubit),
        BlocProvider(create: (_) => _moviesCubit),
      ],
      child: Scaffold(
        appBar: CustomAppBar.backAppBar(
          showLogoInBackAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: SafeArea(
          child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                10.height,
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    AppStrings.seriesAndMovies.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
                10.height,
                CategoryTabs(onCategorySelected: _onCategorySelected),
                10.height,
                Expanded(
                  child:
                      BlocBuilder<MoviesWithSeriesCubit, MoviesWithSeriesState>(
                        builder: (context, state) {
                          if (state is MoviesWithSeriesLoading) {
                            return Skeletonizer(
                              enabled: true,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 16.h),
                                itemCount: 9,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 20.h,
                                      mainAxisExtent: 200.h,
                                      childAspectRatio: 0.7,
                                    ),
                                itemBuilder: (context, index) {
                                  return MovieOrSeriesCard(
                                    item: MovieOrSeriesItem(
                                      id: index,
                                      name: 'Loading Movie Content',
                                      about: 'Loading about...',
                                      price: '0.00',
                                      actors: const [],
                                      viewsCount: 0,
                                      isReady: true,
                                      adminApproved: true,
                                      coverImage: '',
                                      artWorkType: 'movie',
                                      isPaid: false,
                                      isFavorite: false,
                                      isRated: false,
                                      ratingMean: 0.0,
                                      ratingCount: 0,
                                      createdAt: DateTime.now()
                                          .toIso8601String(),
                                      updatedAt: DateTime.now()
                                          .toIso8601String(),
                                    ),
                                    onTap: () {},
                                  );
                                },
                              ),
                            );
                          }

                          if (state is MoviesWithSeriesError) {
                            // Allow refreshing even on error by using scroll view
                            return RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: 400.h,
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
                              ),
                            );
                          }

                          if (state is MoviesWithSeriesLoaded) {
                            final items = state.response.results;

                            if (items.isEmpty) {
                              return RefreshIndicator(
                                onRefresh: _onRefresh,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: 400.h,
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
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 16.h),
                                itemCount: items.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 20.h,
                                      mainAxisExtent: 200.h,
                                      childAspectRatio: 0.7,
                                    ),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return MovieOrSeriesCard(
                                    item: item,
                                    onTap: () {
                                      context.pushNamed(
                                        Routes.movieDetails,
                                        extra: item,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
