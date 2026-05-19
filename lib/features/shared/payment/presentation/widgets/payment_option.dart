import 'package:flutter/material.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/widgets/svg_image/svg_image_widget.dart';

class PaymentOption extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool selected;
  final Function()? onTap;
  const PaymentOption(
      {super.key,
      required this.title,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.whiteColor)),
        child: Row(
          children: [
            selected
                ? const Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgImageWidget(
                        image: AppIcons.selectedCheck,
                        width: 24,
                        height: 24,
                      ),
                      Icon(
                        Icons.check,
                        color: AppColors.whiteColor,
                        size: 14,
                      )
                    ],
                  )
                : SvgImageWidget(
                    image: AppIcons.circle,
                    width: 24,
                    height: 24,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
