import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'about_section_widget.dart';
import 'actors_section_widget.dart';
import 'rating_section_widget.dart';
import 'series_seasons_episodes_widget.dart';

/// Content displayed AFTER payment (when isPaid = true)
/// Shows: About section, Actors list, Seasons/Episodes (for series), and Rating section
class AfterPaymentContentWidget extends StatelessWidget {
  final MovieOrSeriesItem item;
  final bool isPaid;
  final Function(int) onRateTap;
  final VoidCallback onEpisodePlay;

  const AfterPaymentContentWidget({
    super.key,
    required this.item,
    required this.isPaid,
    required this.onRateTap,
    required this.onEpisodePlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About section - Only for movies, Rating for series
            if (item.isSeries) ...[
              // Rating section for series (in place of About)
              RatingSectionWidget(onRateTap: onRateTap),
              if (item.actors.isNotEmpty) 24.height,
            ] else ...[
              // About section for movies
              AboutSectionWidget(about: item.about, rating: item.ratingMean),
              if (item.actors.isNotEmpty) 24.height,
            ],

            // Actors section
            if (item.actors.isNotEmpty) ...[
              ActorsSectionWidget(actors: item.actors),
              if (item.isSeries) 24.height else 35.height,
            ],

            // Seasons and Episodes section - Only for series
            if (item.isSeries) ...[
              SeriesSeasonsEpisodesWidget(
                seriesId: item.id,
                isPaid: isPaid,
                onEpisodePlay: onEpisodePlay,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
