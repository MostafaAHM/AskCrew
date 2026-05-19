import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final bool isScrollControlled, canClose;
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.isScrollControlled = true,
    this.canClose = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12).r,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16).r,
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*if (canClose)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.all(12.0).r,
                  child: const CustomCloseButton(),
                ),
              ),*/
            isScrollControlled ? Expanded(child: child) : child,
          ],
        ),
      ),
    );
  }
}
