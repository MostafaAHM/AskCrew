import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../config/routes/routes.dart';
import 'package:aflam/features/viewer/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:aflam/features/viewer/favorites/presentation/cubit/favorites_state.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/movie_or_series_card.dart';

class FavoriteArtworkScreen extends StatefulWidget {
  const FavoriteArtworkScreen({super.key});

  @override
  State<FavoriteArtworkScreen> createState() => _FavoriteArtworkScreenState();
}

class _FavoriteArtworkScreenState extends State<FavoriteArtworkScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: SafeArea(
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              20.height,
              Center(
                child: Text(
                  AppStrings.favoriteArtwork.tr(),
                  style: TextStyle(
                    color: AppColors.lightTText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              20.height,
              Expanded(
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoading &&
                        state.favoritesKeys.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is FavoritesError &&
                        state.favoritesKeys.isEmpty) {
                      return Center(child: Text(state.message));
                    }

                    final favorites = state is FavoritesLoaded
                        ? state.favorites
                              .where((e) => state.favoritesKeys.contains(e.key))
                              .toList()
                        : [];

                    if (favorites.isEmpty && state is FavoritesLoaded) {
                      return Center(child: Text(AppStrings.noFavorites.tr()));
                    }

                    return GridView.builder(
                      itemCount: favorites.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        final item = favorite.contentObject;
                        if (item == null) return const SizedBox.shrink();

                        return MovieOrSeriesCard(
                          item: item,
                          onTap: () {
                            context.pushNamed(Routes.movieDetails, extra: item);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              20.height,
            ],
          ),
        ),
      ),
    );
  }
}
