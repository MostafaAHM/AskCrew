import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_trending_repository.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aflam/core/helpers/user_helper.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final GetTrendingRepository _repository = getIt<GetTrendingRepository>();
  List<MovieModel> _trending = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrending();
    
    // Listen to user changes (e.g. after payment) to refresh data
    UserHelper.userNotifier.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    if (mounted) {
      _loadTrending(isRefresh: true);
    }
  }

  @override
  void dispose() {
    UserHelper.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  Future<void> _loadTrending({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result = await _repository.getTrending();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        }
      },
      (response) {
        if (mounted) {
          setState(() {
            _trending = response.results;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
        onBackPressed: () {
          context.pop();
        },
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
              10.height,
              Text(
                'home_trending'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp,
                ),
              ),
              10.height,
              Expanded(
                child: _isLoading
                    ? Skeletonizer(
                        enabled: true,
                        child: GridView.builder(
                          shrinkWrap: false,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 16.h),
                          itemCount: 9,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 16.h,
                                mainAxisExtent: 180.h,
                                childAspectRatio: 0.7,
                              ),
                          itemBuilder: (context, index) {
                            return _TrendingMovieCard(
                              movie: MovieModel(
                                id: index,
                                name: 'Loading Movie',
                                about: 'Loading description...',
                                price: '0.00',
                                actors: const [],
                                viewsCount: 0,
                                isReady: true,
                                adminApproved: true,
                                createdAt: DateTime.now().toIso8601String(),
                                coverImage: '',
                                ratingMean: 0.0,
                              ),
                              onTap: () {},
                            );
                          },
                        ),
                      )
                    : _error != null
                    ? RefreshIndicator(
                        onRefresh: () async => _loadTrending(isRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 500.h,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  16.height,
                                  ElevatedButton(
                                    onPressed: _loadTrending,
                                    child: Text('common_retry'.tr()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : _trending.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async => _loadTrending(isRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 500.h,
                            child: Center(
                              child: Text(
                                'common_no_content_found'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadTrending(isRefresh: true),
                        child: GridView.builder(
                          shrinkWrap: false,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 16.h),
                          itemCount: _trending.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 16.h,
                                mainAxisExtent: 180.h,
                                childAspectRatio: 0.7,
                              ),
                          itemBuilder: (context, index) {
                            final movie = _trending[index];
                            return _TrendingMovieCard(
                              movie: movie,
                              onTap: () {
                                // Navigate to video player using artWorkType from response
                                final contentType =
                                    movie.artWorkType ?? 'movie';
                                context.pushNamed(
                                  Routes.videoPlayer,
                                  pathParameters: {
                                    'contentType': contentType,
                                    'contentId': movie.id.toString(),
                                  },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CustomCachedNetworkImage(
              height: 140.h,
              fit: BoxFit.cover,
              url: movie.coverImage ?? '',
              serverImage: true,
            ),
          ),
          6.height,
          Flexible(
            child: Text(
              movie.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (movie.ratingMean != null) ...[
            2.height,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 12.sp),
                2.width,
                Flexible(
                  child: Text(
                    movie.ratingMean!.toStringAsFixed(1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
