// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';

// import '../../app_config/app_colors.dart';
// import '../../app_config/app_icons.dart';
// import '../../app_config/app_strings.dart';
// import 'custom_button.dart';

// class AuthButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final SocialType type;
//   const AuthButton({
//     super.key,
//     this.onPressed,
//     required this.type,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomButton(
//       onTap: onPressed,
//       text: _stringBuilder(),
//       icon: SvgPicture.asset(_iconBuilder()),
//       hasBorder: true,
//       borderColor: AppColors.borderColor,
//       padding: EdgeInsets.symmetric(vertical: 14.h),
//       backgroundColor: AppColors.secondaryButton,
//       style: TextStyle(
//         fontWeight: FontWeight.w500,
//         fontSize: 14.sp,
//         fontFamily: 'Poppins',
//         color: Colors.white,
//       ),
//     );
//   }

//   String _iconBuilder() {
//     switch (type) {
//       case SocialType.google:
//         return AppIcons.google;
//       case SocialType.facebook:
//         return AppIcons.facebook;
//     }
//   }

//   String _stringBuilder() {
//     switch (type) {
//       case SocialType.google:
//         return AppStrings.google.tr();
//       case SocialType.facebook:
//         return AppStrings.facebook.tr();
//     }
//   }
// }

// enum SocialType { google, facebook }
