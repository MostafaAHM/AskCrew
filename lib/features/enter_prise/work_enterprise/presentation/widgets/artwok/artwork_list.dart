import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../config/routes/routes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/get_movies_cubit.dart';
import '../../cubit/get_movies_state.dart';
import '../../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';
import '../../cubit/content_management_cubit.dart';
import 'artwork_card.dart';

class ArtworkList extends StatefulWidget {
  final Color orange;

  const ArtworkList({super.key, required this.orange});

  @override
  State<ArtworkList> createState() => _ArtworkListState();
}

class _ArtworkListState extends State<ArtworkList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<GetMoviesCubit>().getMovies(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GetMoviesCubit>().getMovies();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMoviesCubit, GetMoviesState>(
      builder: (context, state) {
        if (state is GetMoviesLoading && state is! GetMoviesLoaded) {
          return ListView.separated(
            padding: EdgeInsets.only(bottom: 80.h),
            itemCount: 6,
            separatorBuilder: (_, __) => 12.height,
            itemBuilder: (_, __) => CustomShimmerWidget(
              width: double.infinity,
              height: 140.h,
              borderRadius: BorderRadius.circular(16.r),
            ),
          );
        } else if (state is GetMoviesError) {
          return Center(child: Text(state.message));
        } else if (state is GetMoviesLoaded) {
          final movies = state.movies.where((m) => m.isOwner).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<GetMoviesCubit>().getMovies(refresh: true);
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 80.h),
              itemBuilder: (c, i) {
                if (i >= movies.length) {
                  return CustomShimmerWidget(
                    width: double.infinity,
                    height: 140.h,
                    borderRadius: BorderRadius.circular(16.r),
                  );
                }
                final movie = movies[i];
                return ArtworkCard(
                  orange: widget.orange,
                  date: _formatDate(movie.createdAt),
                  imageUrl: movie.coverImage ?? '',
                  rating: movie.ratingMean ?? 0.0,
                  subscribers: movie.subscribedCount,
                  title: movie.name,
                  views: movie.viewsCount.toString(),
                  price: movie.price,
                  isOwner: movie.isOwner,
                  isReady: movie.isReady,
                  onDelete: () {
                    context.read<GetMoviesCubit>().removeMovie(movie.id);
                    context.read<ContentManagementCubit>().deleteMovie(
                      movie.id,
                    );
                  },
                  onEdit: () async {
                    final result = await context.pushNamed(
                      Routes.uploadMovie,
                      extra: movie,
                    );
                    if (result == true && context.mounted) {
                      context.read<GetMoviesCubit>().getMovies(refresh: true);
                    }
                  },
                  onTap: () {
                    context.pushNamed(Routes.moviePreview, extra: movie);
                  },
                );
              },
              separatorBuilder: (_, __) => 6.height,
              itemCount: state.hasMore ? movies.length + 1 : movies.length,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
