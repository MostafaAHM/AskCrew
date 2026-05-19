import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'about_section_widget.dart';
import 'actors_section_widget.dart';
import 'series_seasons_episodes_widget.dart';

/// Content displayed BEFORE payment (when isPaid = false)
/// Shows: About section, Actors list, Seasons/Episodes (for series), and Pay button
class BeforePaymentContentWidget extends StatelessWidget {
  final MovieOrSeriesItem item;
  final double price;
  final VoidCallback onPaymentTap;
  final VoidCallback onEpisodePlay;

  const BeforePaymentContentWidget({
    super.key,
    required this.item,
    required this.price,
    required this.onPaymentTap,
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
            // About section - Only for movies, not for series (series shows seasons/episodes instead)
            if (!item.isSeries) ...[
              AboutSectionWidget(about: item.about, rating: item.ratingMean),
              if (item.actors.isNotEmpty) 24.height,
            ],

            // Actors section
            if (item.actors.isNotEmpty) ...[
              ActorsSectionWidget(actors: item.actors),
              if (item.isSeries) 24.height else 35.height,
            ],

            // Seasons and Episodes section - Only for series (browsable before payment)
            if (item.isSeries) ...[
              SeriesSeasonsEpisodesWidget(
                seriesId: item.id,
                isPaid: false, // Can browse but not play
                onEpisodePlay: onEpisodePlay,
              ),
              35.height,
            ],

            // Pay button - Only shown before payment
            CustomButton(
              text: "Pay \$${price.toStringAsFixed(2)}",
              isBackgroundGradient: true,
              onTap: onPaymentTap,
            ),
          ],
        ),
      ),
    );
  }
}
