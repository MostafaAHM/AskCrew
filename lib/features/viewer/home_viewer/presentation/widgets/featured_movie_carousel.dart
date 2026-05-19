import 'dart:async';

import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';

class FeaturedMovieCarousel extends StatefulWidget {
  const FeaturedMovieCarousel({super.key});

  @override
  State<FeaturedMovieCarousel> createState() => _FeaturedMovieCarouselState();
}

class _FeaturedMovie {
  final String title;
  final String date;
  final double rating;
  final String imagePath;
  final bool isNewest;

  const _FeaturedMovie({
    required this.title,
    required this.date,
    required this.rating,
    required this.imagePath,
    this.isNewest = false,
  });
}

class _FeaturedMovieCarouselState extends State<FeaturedMovieCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  final List<_FeaturedMovie> _items = const [
    _FeaturedMovie(
      title: 'La La Land',
      date: '4 Oct 2025',
      rating: 4.9,
      imagePath: 'assets/icons/banner.png',
      isNewest: true,
    ),
    _FeaturedMovie(
      title: 'Interstellar',
      date: '12 Jun 2024',
      rating: 4.8,
      imagePath: 'assets/icons/banner.png',
    ),
    _FeaturedMovie(
      title: 'Inception',
      date: '18 Mar 2023',
      rating: 4.7,
      imagePath: 'assets/icons/banner.png',
    ),
    _FeaturedMovie(
      title: 'Whiplash',
      date: '2 Jan 2022',
      rating: 4.9,
      imagePath: 'assets/icons/banner.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _items.isEmpty) return;
      final nextPage = (_currentIndex + 1) % _items.length;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 185.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _FeaturedMovieCard(movie: item),
              );
            },
          ),
        ),
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
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
}

class _FeaturedMovieCard extends StatelessWidget {
  final _FeaturedMovie movie;

  const _FeaturedMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 160.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  movie.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
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
              if (movie.isNewest)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B2C),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'The Newest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 12.w,
                right: 48.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    4.height,
                    Text(
                      movie.date,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 15.sp,
                          color: const Color(0xFFFFC107),
                        ),
                        4.width,
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12.w,
                bottom: 16.h,
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.45),
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 16.sp,
                    color: Colors.white,
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
