import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const Color secondaryColor = Color(0xFFFE5B00);
  static const Color primaryColor = Color(0xFF50177A);

  static const Color lightBGColor = Color(0xFFF9F9F5);
  static const Color darkBGColor = Color(0xFF1E1E1E);

  static const Color lightMainText = Color(0xFF464749);
  static const Color darkMainText = Color(0xFFFFFFFF);

  static const Color lightSecMainText = Color(0xFF6D6D6D);
  static const Color darkSecMainText = Color(0xFFB8B8B8);

  static const Color greyText = Color(0xFF7E7D88);
  static const Color lightGreyText = Color(0xFFB8B8B8);
  static const Color darkGreyText = Color(0xFF615B5C);

  static const Color lightTText = Color(0xFF1E1E1E);
  static const Color darkTText = Color(0xFFFFFFFF);

  static const Color iconButtonBG = Color(0xFFF9F9F5);
  static const Color lightGreyDividerColor = Color(0xFFB8B8B8);
  static const Color lightGDividerColor = Color(0xFFD9D9D9);
  static const Color chatLightBgColor = Color(0xFFF9F9F5);

  static const Color offerOptionsBorder = Color(0xFFD9D9D9);

  static const Color whatsAppGreen = Color(0xFF25D366);
  static const Color purple = Color(0xFF50177A);

  static const Color lightSecGreyText = Color(0xFF919191);

  static const Color lightImageBgColor = Color(0xFFF9F9F5);
  static const Color darkImageBgColor = Color(0xFF353637);

  static const Color redColor = Color(0xFFDF0612);
  static const Color yellowColor = Color(0xFFFE5B00);

  static const Color myChatBubbleColor = Color(0xFFFE5B00);

  static const Color dateColor = Color(0xFFB8B8B8);

  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

  static const Color subColor = Color(0xFFF9F9F5);
  static const Color bodyText = Color(0xFF6D6D6D);

  static const Color secondaryButton = Color(0xFF353637);
  static const Color borderColor = Color(0xFFD9D9D9);

  static const Color errorColor = Colors.red;

  static const Color barColor = Color(0xFF50177A);
  static const Color iconColor = Color(0xFFFE5B00);

  static const Color hintColor = Color(0xFFB8B8B8);

  static const Color bottomBarColor = Color(0xFF1E1E1E);

  static const Color subTitleColor = Color(0xFF6D6D6D);
  static const Color dividerColor = Color(0xFFD9D9D9);
  static const Color profileDividerColor = Color(0xFFC8C8C8);

  static const Color green = Color(0xFF34C759);
  static const Color greenBorder = Color(0xFF25D366);
  static const Color lightGreen = Color(0xFFE8FFF4);

  static const Color sliderColor = Color(0xFFFE5B00);
  static const Color categoryColor = Color(0xFFF9F9F5);
  static const Color descriptionColor = Color(0xFF6D6D6D);
  static const Color imageBgColor = Color(0xFFF9F9F5);

  static const Color lightShadow = Color(0x26B8B8B8);

  static const RadialGradient editProfileGradient = RadialGradient(
    center: Alignment(0.0, -0.3844),
    radius: 0.8641,
    colors: [Color(0xFF50177A), Color(0xFFFE5B00)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient borderGradient = LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient priceGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFE5B00), Color(0xFF50177A)],
    stops: [0.0, 1.0],
  );

  static LinearGradient bottomNavBarGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF353637), Color(0xFF1E1E1E)],
    stops: [0.0, 1.0],
  );

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient transparentGradient = const LinearGradient(
    colors: [Colors.transparent, Colors.transparent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient whiteGradient = const LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient buttonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFE5B00),
      Color(0xFFED550C),
      Color(0xFFDE4F16),
      Color(0xFFD14920),
      Color(0xFFA33840),
      Color(0xFF50177A),
    ],
    stops: [0.0, 0.0962, 0.1827, 0.262, 0.524, 0.851],
  );

  static LinearGradient sliderGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFE5B00), Color(0xFFED550C)],
    stops: [0.0, 1.0],
  );

  static RadialGradient iconButtonGradient = const RadialGradient(
    center: Alignment(0.0, -0.38),
    radius: 1.0,
    colors: [secondaryColor, primaryColor],
    stops: [0.0, 1.0],
  );

  static RadialGradient secondaryGradient = RadialGradient(
    colors: const [AppColors.primaryColor, AppColors.secondaryColor],
    radius: 4.r,
  );
}
