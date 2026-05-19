import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? extra}) {
    return GoRouter.of(this).pushNamed(routeName, extra: extra);
  }

  void go(String routeName, {Object? extra}) {
    GoRouter.of(this).go(routeName, extra: extra);
  }

  Future<dynamic> push(String routeName, {Object? extra}) {
    return GoRouter.of(this).push(routeName, extra: extra);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? extra}) {
    return GoRouter.of(this).pushReplacementNamed(routeName, extra: extra);
  }

  void goNamed(String routeName, {Object? extra}) {
    GoRouter.of(this).goNamed(routeName, extra: extra);
  }

  void pop([Object? result]) {
    GoRouter.of(this).pop(result);
  }
}

extension LangHelper on String {
  String detectLanguage() {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(this) ? 'ar' : 'en';
  }
}
