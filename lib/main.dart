import 'package:aflam/aflam_app.dart';
import 'package:aflam/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/locale/locales.dart';
import 'config/routes/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/helpers/bloc_observer.dart';
import 'core/package_info_helper/package_info_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import 'features/shared/notifications/data/services/local_notifications_service.dart';
import 'features/shared/notifications/data/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WindowsVideoPlayer.registerWith();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = MyBlocObserver();

  await EasyLocalization.ensureInitialized();

  await PackageInfoHelper.initialize();

  await setupServiceLocator();
  await getIt<LocalNotificationsService>()
      .init(); // Initialize Local Notifications
  await getIt<FcmService>().init(); // Initialize FCM Push Notifications
  debugRepaintRainbowEnabled = false;

  runApp(
    EasyLocalization(
      ignorePluralRules: false,
      startLocale: AppLocales.supportedLocales.last,
      supportedLocales: AppLocales.supportedLocales,
      fallbackLocale: AppLocales.supportedLocales.first,
      saveLocale: true,
      path: 'assets/translations',
      child: AflamApp(appRouter: AppRouter()),
    ),
  );
}
