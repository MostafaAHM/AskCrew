import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/widgets/svg_image/svg_image_widget.dart';
import '../screens/payment_screen.dart';
import 'payment_option.dart';

class PaymentOptions extends StatelessWidget {
  const PaymentOptions({
    super.key,
    required this.selectedOption,
  });
  final ValueNotifier<PaymentMethod?> selectedOption;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentMethod?>(
      valueListenable: selectedOption,
      builder: (context, value, child) {
        return Column(
          children: [
            PaymentOption(
              title: AppStrings.creditCard.tr(),
              icon: SizedBox(
                child: Row(
                  children: [
                    const SvgImageWidget(image: AppIcons.mastercard),
                    const SvgImageWidget(image: AppIcons.visa),
                  ],
                ),
              ),
              selected: value == PaymentMethod.card,
              onTap: () {
                selectedOption.value = PaymentMethod.card;
              },
              // Replace with actual asset
            ),
            /*   const SizedBox(height: 12),
                        PaymentOption(
                          title: AppStrings.fawry.tr(),
                          icon: const SvgImageWidget(image: AppIcons.fawry),
                          selected: value == PaymentType.fawry,
                          onTap: () {
                            selectedOption.value = PaymentType.fawry;
                          },
                          // Replace with actual asset
                        ),*/
          ],
        );
      },
    );
  }
}
