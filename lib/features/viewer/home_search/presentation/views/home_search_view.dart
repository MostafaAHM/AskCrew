import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/widgets/fields/custom_search_bar.dart';
import 'package:aflam/core/widgets/movie_card/movie_card_widget.dart';
import 'package:aflam/core/widgets/sections/section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../config/routes/routes.dart';
import '../cubit/home_search_cubit.dart';
import '../cubit/home_search_state.dart';

class HomeSearchView extends StatefulWidget {
  const HomeSearchView({super.key});

  @override
  State<HomeSearchView> createState() => _HomeSearchViewState();
}

class _HomeSearchViewState extends State<HomeSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeSearchCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.lightBGColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.lightBGColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Builder(
            builder: (context) {
              return CustomSearchBar(
                controller: _searchController,
                showClearButton: true,
                autoFocus: true,
                onChanged: (value) {
                  context.read<HomeSearchCubit>().searchMovies(value);
                },
              );
            },
          ),
        ),
        body: BlocBuilder<HomeSearchCubit, HomeSearchState>(
          builder: (context, state) {
            if (state is HomeSearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeSearchError) {
              return Center(child: Text(state.message));
            } else if (state is HomeSearchEmpty) {
              return Center(
                child: Text(
                  AppStrings.noResultsFound.tr(),
                  style: FontStyles.textStyle16,
                ),
              );
            } else if (state is HomeSearchLoaded) {
              if (state.movies.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noResultsFound.tr(),
                    style: FontStyles.textStyle16,
                  ),
                );
              }

              final searchResult = state.movies.first;
              final similarMovies = state.movies.length > 1
                  ? state.movies.sublist(1)
                  : [];

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "What you are looking for" Section
                    SectionWidget(
                      title: AppStrings.whatYouAreLookingFor.tr(),
                      titleStyle: FontStyles.textStyle18.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightMainText,
                      ),
                      titleAndContentSpace: 16.h,
                      content: MovieCardWidget(
                        movie: searchResult,
                        onTap: () {
                          context.pushNamed(
                            Routes.movieDetails,
                            pathParameters: {'id': searchResult.id},
                          );
                        },
                      ),
                    ),
                    24.height,
                    // "Similar Films" Section
                    if (similarMovies.isNotEmpty) ...[
                      SectionWidget(
                        title: AppStrings.similarFilms.tr(),
                        titleStyle: FontStyles.textStyle18.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightMainText,
                        ),
                        titleAndContentSpace: 16.h,
                        content: Column(
                          children: similarMovies
                              .map(
                                (movie) => Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: MovieCardWidget(
                                    movie: movie,
                                    onTap: () {
                                      context.pushNamed(
                                        Routes.movieDetails,
                                        pathParameters: {'id': movie.id},
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
