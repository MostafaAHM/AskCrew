import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';
import 'package:flutter/material.dart';

import 'after_payment_content_widget.dart';
import 'before_payment_content_widget.dart';

/// Main content section that switches between before/after payment states
class ContentDetailsSectionWidget extends StatelessWidget {
  final MovieOrSeriesItem item;
  final bool isPaid;
  final double price;
  final VoidCallback onPaymentTap;
  final Function(int) onRateTap;
  final VoidCallback onEpisodePlay;

  const ContentDetailsSectionWidget({
    super.key,
    required this.item,
    required this.isPaid,
    required this.price,
    required this.onPaymentTap,
    required this.onRateTap,
    required this.onEpisodePlay,
  });

  @override
  Widget build(BuildContext context) {
    // Show different content based on payment status
    if (isPaid) {
      // AFTER PAYMENT: Show rating section
      return AfterPaymentContentWidget(
        item: item,
        isPaid: isPaid,
        onRateTap: onRateTap,
        onEpisodePlay: onEpisodePlay,
      );
    } else {
      // BEFORE PAYMENT: Show pay button
      return BeforePaymentContentWidget(
        item: item,
        price: price,
        onPaymentTap: onPaymentTap,
        onEpisodePlay: onEpisodePlay,
      );
    }
  }
}
