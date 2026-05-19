import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Action buttons section (Pay and Rate buttons)
class ActionButtonsSectionWidget extends StatelessWidget {
  final bool showPaymentButton;
  final bool showRateButton;
  final double price;
  final VoidCallback onPaymentTap;
  final VoidCallback onRateTap;

  const ActionButtonsSectionWidget({
    super.key,
    required this.showPaymentButton,
    required this.showRateButton,
    required this.price,
    required this.onPaymentTap,
    required this.onRateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showPaymentButton) ...[
          CustomButton(
            text: "Pay \$${price.toStringAsFixed(2)}",
            isBackgroundGradient: true,
            onTap: onPaymentTap,
          ),
        ],
        if (showRateButton) ...[
          CustomButton(
            text: "Rate".tr(),
            isBackgroundGradient: false,
            onTap: onRateTap,
          ),
        ],
      ],
    );
  }
}
