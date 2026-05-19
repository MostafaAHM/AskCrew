import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class PromoCodeBottomSheet extends StatefulWidget {
  final Function(String? code, bool withWallet, bool usePoints) onApply;
  final VoidCallback onCancel;
  final String? initialCode;
  final bool showWalletOption;

  const PromoCodeBottomSheet({
    super.key,
    required this.onApply,
    required this.onCancel,
    this.initialCode,
    this.showWalletOption = true,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String? code, bool withWallet, bool usePoints) onApply,
    required VoidCallback onCancel,
    String? initialCode,
    bool showWalletOption = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => PromoCodeBottomSheet(
        onApply: onApply,
        onCancel: onCancel,
        initialCode: initialCode,
        showWalletOption: showWalletOption,
      ),
    ).then((_) {
      // Ensure onCancel is called if dismissed by tapping outside/drag
      // We can rely on the widget state to know if it was handled manually
    });
  }

  @override
  State<PromoCodeBottomSheet> createState() => _PromoCodeBottomSheetState();
}

class _PromoCodeBottomSheetState extends State<PromoCodeBottomSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _codeController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _showError = false;
  bool _withWallet = false;
  bool _usePoints = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Initial delay for smooth entrance after sheet opens
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _animController.reverse();
    if (mounted) {
      context.pop();
      widget.onCancel();
    }
  }

  void _handleApply() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _showError = true;
      });
      // Shake effect or simple error
      return;
    }
    await _animController.reverse();
    if (mounted) {
      context.pop();
      widget.onApply(code.isEmpty ? null : code, _withWallet, _usePoints);
    }
  }

  void _handleSkip() async {
    await _animController.reverse();
    if (mounted) {
      context.pop();
      widget.onApply(null, _withWallet, _usePoints);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle keyboard padding
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              20.verticalSpace,

              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.ticket,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Text(
                      AppStrings.havePromoCode.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _handleClose,
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              24.verticalSpace,

              // Body
              Text(
                'promoCodeDescription'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              20.verticalSpace,

              CustomTextField(
                controller: _codeController,
                hint: AppStrings.promoCode.tr(),
                prefix: Icon(
                  Icons.discount_outlined,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
                onChanged: (val) {
                  if (_showError && val.isNotEmpty) {
                    setState(() => _showError = false);
                  }
                },
              ),

              if (_showError) ...[
                6.verticalSpace,
                Row(
                  children: [
                    Icon(Icons.error_outline, size: 14.sp, color: Colors.red),
                    6.horizontalSpace,
                    Text(
                      AppStrings.enterCodeError.tr(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.red),
                    ),
                  ],
                ),
              ],

              16.verticalSpace,

              if (widget.showWalletOption)
                SwitchListTile(
                  title: Text(
                    AppStrings.payWithWallet.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  value: _withWallet,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _withWallet = val;
                    });
                  },
                ),

              SwitchListTile(
                title: Text(
                  AppStrings.usePoints.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                value: _usePoints,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (val) {
                  setState(() {
                    _usePoints = val;
                  });
                },
              ),

              24.verticalSpace,

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton.outlined(
                      text: AppStrings.back.tr(), // Using 'back' as Cancel/Back
                      onTap: _handleClose,
                      height: 48.h,
                      borderColor: Colors.grey.shade300,
                      textColor: Colors.grey.shade700,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: CustomButton.filled(
                      text: AppStrings.applyCode.tr(),
                      onTap: _handleApply,
                      height: 48.h,
                    ),
                  ),
                ],
              ),

              16.verticalSpace,

              GestureDetector(
                onTap: _handleSkip,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    AppStrings.skip.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // Bottom padding for keyboard + safety
              SizedBox(height: bottomPadding > 0 ? bottomPadding + 16.h : 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
