import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/widgets/settings/language_selector.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: AppColors.lightBGColor,
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LanguageSelector(
                currentLocale: currentLocale,
                onLanguageChanged: (newLocale) async {
                  if (newLocale == context.locale) return;
                  await context.setLocale(newLocale);
                   setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
