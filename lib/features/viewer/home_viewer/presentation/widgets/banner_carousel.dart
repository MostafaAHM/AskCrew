import 'dart:async';

import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/features/viewer/favorites/presentation/widgets/favorite_button.dart';
import '../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../data/model/banner_model.dart';
import '../cubit/banner_cubit.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    context.read<BannerCubit>().getBanners();
  }

  void _startAutoScroll(List<BannerModel> banners) {
    _autoScrollTimer?.cancel();
    if (banners.isEmpty) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || banners.isEmpty) return;
      final nextPage = (_currentIndex + 1) % banners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onBannerTap(BannerModel banner) {
    final contentObject = banner.contentObject;
    if (contentObject == null) return;

    final contentType = banner.contentType;
    final isAd = contentType.toLowerCase() == 'advertise';


    if (isAd) {
      context.pushNamed(
        Routes.trailerPlayer,
        pathParameters: {
          'contentType': contentType,
          'contentId': contentObject.id.toString(),
        },
      );
    } else {
      context.pushNamed(
        Routes.trailerPlayer,
        pathParameters: {
          'contentType': contentType,
          'contentId': contentObject.id.toString(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        if (state is BannerLoading) {
          return SizedBox(
            height: 185.h,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: CustomShimmerWidget(
                    height: 160.h,
                    borderRadius: BorderRadius.circular(15.r),
                    width: double.infinity,
                  ),
                );
              },
            ),
          );
        }

        if (state is BannerFailure) {
          return const SizedBox.shrink();
        }

        if (state is BannerSuccess) {
          final banners = state.response.results
              .where(
                (banner) => banner.isActive && banner.contentObject != null,
              )
              .toList();

          if (banners.isEmpty) {
            return const SizedBox.shrink();
          }

          // Start auto scroll when banners are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll(banners);
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 185.h,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _BannerCard(
                        banner: banner,
                        onTap: () => _onBannerTap(banner),
                      ),
                    );
                  },
                ),
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: index == _currentIndex ? 18.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99.r),
                      color: index == _currentIndex
                          ? AppColors.primaryColor
                          : Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onTap;

  const _BannerCard({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final contentObject = banner.contentObject;
    if (contentObject == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 160.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: CustomCachedNetworkImage(
                  url: contentObject.coverImage ?? '',
                  serverImage: true,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Play Button
              Center(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
              ),
              // Content Info
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contentObject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contentObject.ratingMean != null) ...[
                      4.height,
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 15.sp,
                            color: const Color(0xFFFFC107),
                          ),
                          4.width,
                          Text(
                            contentObject.ratingMean!.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 12.w,
                bottom: 16.h,
                child: FavoriteButton(
                  contentType: banner.contentType,
                  objectId: contentObject.id,
                  variant: FavoriteStyleVariant.banner,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
