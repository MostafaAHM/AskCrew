import 'package:flutter/material.dart';

import '../../core/app_config/app_colors.dart';
import '../../core/app_config/font_styles.dart';

class AflamAppTheme {
  static final ThemeData lightTheme = ThemeData(fontFamily: 'Tajawal').copyWith(
    appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
    hintColor: AppColors.borderColor,
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      // surface: AppColors.lightBGColor,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerColor,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.lightBGColor,
    textTheme: TextTheme(
      labelLarge: FontStyles.label24.copyWith(color: AppColors.lightMainText),
      // TextStyle(
      //     color: AppColors.lightMainText,
      //     fontSize: 24.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      // field label style
      labelMedium: FontStyles.label16.copyWith(
        color: AppColors.lightSecMainText,
      ),
      titleMedium: FontStyles.body14W700.copyWith(
        color: AppColors.lightSecMainText,
      ),
      // TextStyle(
      //     color: AppColors.lightSecMainText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      // text button style
      labelSmall: FontStyles.label16.copyWith(color: AppColors.lightGreyText),
      // TextStyle(
      //     color: AppColors.lightGreyText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //primary text style
      headlineLarge: FontStyles.headline14.copyWith(
        color: AppColors.primaryColor,
      ),
      //  TextStyle(
      //     color: AppColors.primaryColor,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //button white  text style
      headlineMedium: FontStyles.headline16.copyWith(
        color: AppColors.whiteColor,
      ),
      // TextStyle(
      //     color: AppColors.whiteColor,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //button black  text style
      headlineSmall: FontStyles.headline16.copyWith(
        color: AppColors.lightMainText,
      ),
      //  TextStyle(
      //     color: AppColors.lightMainText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),

      // body text
      bodyLarge: FontStyles.body14W700.copyWith(color: AppColors.bodyText),
      //  TextStyle(
      //     color: AppColors.bodyText,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      bodyMedium: FontStyles.body14W500.copyWith(
        color: AppColors.lightSecMainText,
      ),
      // TextStyle(
      //     color: AppColors.lightSecMainText,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w500,
      //     fontFamily: 'Tajawal'),
      bodySmall: FontStyles.body12W400.copyWith(color: AppColors.greyText),

      // TextStyle(
      //     color: AppColors.greyText,
      //     fontSize: 12.sp,
      //     fontWeight: FontWeight.w400,
      //     fontFamily: 'Tajawal'),
      titleLarge: FontStyles.body14W500.copyWith(color: AppColors.lightTText),
      titleSmall: FontStyles.body14W700.copyWith(color: AppColors.dateColor),
    ),
    // dialogTheme: DialogThemeData(backgroundColor: AppColors.lightBGColor),
  );
  static final ThemeData darkTheme = ThemeData(fontFamily: 'Tajawal').copyWith(
    appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
    iconTheme: IconThemeData(color: AppColors.whiteColor),
    hintColor: AppColors.borderColor,
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.darkBGColor,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerColor,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.darkBGColor,
    textTheme: TextTheme(
      labelLarge: FontStyles.label24.copyWith(color: AppColors.darkMainText),
      // TextStyle(
      //     color: AppColors.lightMainText,
      //     fontSize: 24.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      // field label style
      labelMedium: FontStyles.label16.copyWith(
        color: AppColors.darkSecMainText,
      ),
      // TextStyle(
      //     color: AppColors.lightSecMainText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      // text button style
      labelSmall: FontStyles.label16.copyWith(color: AppColors.darkGreyText),
      // TextStyle(
      //     color: AppColors.lightGreyText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //primary text style
      headlineLarge: FontStyles.headline14.copyWith(
        color: AppColors.primaryColor,
      ),
      //  TextStyle(
      //     color: AppColors.primaryColor,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //button white  text style
      headlineMedium: FontStyles.headline16.copyWith(
        color: AppColors.whiteColor,
      ),
      // TextStyle(
      //     color: AppColors.whiteColor,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      //button black  text style
      headlineSmall: FontStyles.headline16.copyWith(
        color: AppColors.darkMainText,
      ),
      //  TextStyle(
      //     color: AppColors.lightMainText,
      //     fontSize: 16.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),

      // body text
      bodyLarge: FontStyles.body14W700.copyWith(color: AppColors.bodyText),
      //  TextStyle(
      //     color: AppColors.bodyText,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w700,
      //     fontFamily: 'Tajawal'),
      bodyMedium: FontStyles.body14W500.copyWith(
        color: AppColors.darkSecMainText,
      ),
      // TextStyle(
      //     color: AppColors.lightSecMainText,
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w500,
      //     fontFamily: 'Tajawal'),
      bodySmall: FontStyles.body12W400.copyWith(color: AppColors.darkGreyText),

      // TextStyle(
      //     color: AppColors.greyText,
      //     fontSize: 12.sp,
      //     fontWeight: FontWeight.w400,
      //     fontFamily: 'Tajawal'),
      titleLarge: FontStyles.body14W500.copyWith(color: AppColors.darkTText),
      titleSmall: FontStyles.body14W700.copyWith(color: AppColors.dateColor),
    ),
    // dialogTheme: DialogThemeData(backgroundColor: AppColors.darkBGColor),
  );

  get lightMode {
    return lightTheme;
  }

  get darkMode {
    return darkTheme;
  }
}
