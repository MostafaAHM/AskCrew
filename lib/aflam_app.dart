import 'package:aflam/core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'package:aflam/features/enter_prise/home_enterprise/presentation/cubit/home_enterprise_cubit.dart';
import 'package:aflam/features/student/home_student/presentation/cubit/home_student_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/viewer/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/themes/theme.dart';

import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';

class AflamApp extends StatefulWidget {
  final AppRouter appRouter;

  const AflamApp({super.key, required this.appRouter});

  @override
  State<AflamApp> createState() => _AflamAppState();
}

class _AflamAppState extends State<AflamApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      fontSizeResolver: (fontSize, screenUtil) {
        return fontSize * screenUtil.scaleWidth.clamp(0.8, 1);
      },
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => BottomNavigationCubit()),
            BlocProvider(create: (context) => HomeStudentCubit()),
            BlocProvider(create: (context) => HomeEnterpriseCubit()),
            BlocProvider(
              create: (context) => getIt<FavoritesCubit>()..loadFavorites(),
            ),
            BlocProvider(
              create: (context) => getIt<NotificationsCubit>()..init(),
            ),
          ],
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: MaterialApp.router(
              key: ValueKey(context.locale.languageCode),
              routerConfig: AppRouter.router,
              theme: AflamAppTheme.lightTheme,
              themeMode: ThemeMode.light,
              debugShowCheckedModeBanner: false,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              title: 'Aflam App',
            ),
          ),
        );
      },
    );
  }
}
