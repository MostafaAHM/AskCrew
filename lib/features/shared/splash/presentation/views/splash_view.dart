import 'dart:convert';

import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/helpers/secure_local_storage.dart';
import 'package:aflam/core/network/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../auth/login/data/model/response/user_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.75, curve: Curves.easeOutQuint),
          ),
        );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 1.0, curve: Curves.easeOutQuint),
          ),
        );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  Future<void> _handleNavigation() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      /// 🔒 FIREBASE REMOTE CONFIG (APP LOCK)
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(seconds: 0), // للتجربة
        ),
      );

      /// مهم جدًا
      await remoteConfig.setDefaults({'app_enabled': true});

      await remoteConfig.fetch();
      await remoteConfig.activate();

      final bool appEnabled = remoteConfig.getBool('app_enabled');
      debugPrint('🔥 app_enabled = $appEnabled');

      if (!appEnabled) {
        if (!mounted) return;
        context.go(Routes.appLocked);
        return;
      }

      /// 🔑 TOKEN
      final token = await SecureLocalStorage.read(PrefsKeys.token);

      if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
        final dioService = getIt<DioService>();
        final refreshSuccess = await dioService.refreshToken().timeout(
          const Duration(seconds: 10),
          onTimeout: () => false,
        );

        if (!refreshSuccess) {
          _navigateToModuleSelection();
          return;
        }
      }

      /// 👤 USER
      final userJson = await SecureLocalStorage.read(PrefsKeys.user);
      String? type;

      if (userJson != null && userJson.isNotEmpty) {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(decoded);
        UserHelper.setUser(user);
        type = decoded['type'] as String?;
      }

      if (!mounted) return;
      _navigateToHome(type);
    } catch (e) {
      debugPrint('❌ Splash Error: $e');
      if (!mounted) return;
      _navigateToModuleSelection();
    }
  }

  void _navigateToModuleSelection() {
    if (mounted && context.mounted) {
      context.go(Routes.moduleSelection);
    }
  }

  void _navigateToHome(String? type) {
    if (!mounted || !context.mounted) return;

    switch (type) {
      case 'enterprise':
        context.go(Routes.enterpriseHome);
        break;
      case 'viewer':
        context.go(Routes.viewerHome);
        break;
      case 'student':
        context.go(Routes.studentHome);
        break;
      default:
        context.go(Routes.moduleSelection);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(AppIcons.backgroundPNG, fit: BoxFit.fitHeight),
          ),
          Container(color: const Color(0x8C000000)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: Image.asset(AppIcons.splash, width: 180.w),
                ),
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontFamily: 'Poppins',
                        ),
                        children: const [
                          TextSpan(
                            text: 'Ask ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'C',
                            style: TextStyle(color: AppColors.secondaryColor),
                          ),
                          TextSpan(
                            text: 'rew',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
