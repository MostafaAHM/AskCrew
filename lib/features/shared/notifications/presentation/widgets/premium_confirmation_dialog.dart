import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PremiumConfirmationDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color? confirmColor;
  final String? iconPath;

  const PremiumConfirmationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
    this.confirmText = 'confirm',
    this.cancelText = 'cancel',
    this.confirmColor,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    // Simple entrance animation can be done here or by the caller.
    // We'll use a TweenAnimationBuilder for entrance.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: (value - 0.8) * 5, // Map 0.8-1.0 to 0.0-1.0
            child: child,
          ),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null) ...[
                Container(
                  width: 72.w,
                  height: 72.w,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: (confirmColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgImageWidget(
                    image: iconPath!,
                    colorFilter: ColorFilter.mode(
                      confirmColor ?? Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        foregroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        cancelText.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .pop(); // Close dialog first? Or let parent handle?
                        // Requirement: "Smooth collapse when confirmed".
                        // Logic: Dialog closes, then action happens.
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            confirmColor ?? Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
