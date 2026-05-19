import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../app_config/app_colors.dart';
import '../../validations/validators.dart';

class CustomOTPField extends StatefulWidget {
  const CustomOTPField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String?) onCompleted;
  final Function(String?) onChanged;

  @override
  State<CustomOTPField> createState() => _CustomOTPFieldState();
}

class _CustomOTPFieldState extends State<CustomOTPField> {
  late PinTheme defaultPinTheme;

  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: const Color(0xFF101828),
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
      ),
    );

    final followingPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.transparent,
        border: Border.all(color: AppColors.secondaryColor, width: 1),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.secondaryColor, width: 1.3),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.errorColor, width: 1.2),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,

        controller: widget.controller,
        focusNode: widget.focusNode,

        defaultPinTheme: defaultPinTheme,
        submittedPinTheme: defaultPinTheme,
        followingPinTheme: followingPinTheme,
        focusedPinTheme: focusedPinTheme,
        errorPinTheme: errorPinTheme,

        separatorBuilder: (index) => 10.width,
        validator: CustomValidators.validateEmpty,
        hapticFeedbackType: HapticFeedbackType.lightImpact,

        onCompleted: widget.onCompleted,
        onChanged: widget.onChanged,

        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 9),
              width: 22.w,
              height: 1,
              color: AppColors.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
