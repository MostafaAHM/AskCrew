import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromoCodeDialog extends StatefulWidget {
  final Function(String? code) onApply;
  final VoidCallback onCancel;

  const PromoCodeDialog({
    super.key,
    required this.onApply,
    required this.onCancel,
  });

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_rounded,
                color: AppColors.primaryColor,
                size: 32.sp,
              ),
            ),
            16.height,
            Text(
              AppStrings.havePromoCode.tr(),
              style:
                  TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTText.withOpacity(
                      0.9,
                    ), // Assuming standard dark text color logic, using black/dark grey
                  ).copyWith(
                    color: Colors.black87,
                  ), // Override to ensure dark text on white dialog
              textAlign: TextAlign.center,
            ),
            8.height,
            Text(
              AppStrings.promoCodeDescription.tr(),
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              textAlign: TextAlign.center,
            ),
            24.height,
            CustomTextField(
              controller: _codeController,
              hint: AppStrings.enterPromoCode.tr(),
              prefix: Icon(
                Icons.confirmation_number_outlined,
                size: 20.sp,
                color: AppColors.greyText,
              ),
            ),
            24.height,
            Row(
              children: [
                Expanded(
                  child: CustomButton.outlined(
                    text: AppStrings.skip.tr(),
                    borderColor: AppColors.greyText.withOpacity(0.5),
                    textColor: AppColors.greyText,
                    onTap: () {
                      widget.onApply(null);
                    },
                  ),
                ),
                12.width,
                Expanded(
                  child: CustomButton.filled(
                    text: AppStrings.apply.tr(),
                    onTap: () {
                      if (_codeController.text.isNotEmpty) {
                        widget.onApply(_codeController.text);
                      } else {
                        // Optionally show error or just do nothing
                        // For now we can treat empty as skip or just enforce input
                        // Let's enforce input for Apply button
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
