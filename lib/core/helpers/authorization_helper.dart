import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/routes.dart';
import '../../features/auth/login/data/model/response/user_model.dart';
import 'user_helper.dart';

class AuthorizationHelper {
  static bool isProducer() {
    final UserModel? user = UserHelper.userNotifier.value;
    if (user == null) return false;

    // List of all production-related subcategories
    const productionSubcategories = [
      'producer',
      'executive_producer',
      'line_producer',
      'co_producer',
      'production_manager',
      'production_assistant',
      'production_coordinator',
      'location_manager',
    ];

    // Check if any of the production subcategories are present in user's data
    bool hasProductionSubcategory(List<String> specs) {
      return specs.any(
        (spec) => productionSubcategories.any(
          (subcategory) =>
              spec.toLowerCase().contains(subcategory.toLowerCase()),
        ),
      );
    }

    // Extract specs from dynamic specification
    List<String> extractSpecs(dynamic spec) {
      final List<String> result = [];
      if (spec == null) return result;
      if (spec is List) {
        for (final item in spec) {
          result.add(item.toString());
        }
        return result;
      }
      if (spec is Map) {
        for (final value in spec.values) {
          result.add(value.toString());
        }
        return result;
      }
      if (spec is String) {
        try {
          final List<dynamic> jsonList = jsonDecode(spec);
          for (final item in jsonList) {
            result.add(item.toString());
          }
        } catch (_) {
          final parts = spec.split(RegExp(r'[,;]'));
          for (final part in parts) {
            final trimmed = part.trim();
            if (trimmed.isNotEmpty) {
              result.add(trimmed);
            }
          }
        }
      }
      return result;
    }

    // 1. Check specification field
    if (user.profile != null && user.profile!.specification != null) {
      final specs = extractSpecs(user.profile!.specification);
      if (hasProductionSubcategory(specs)) {
        return true;
      }
    }

    // 2. Check personalInfo field
    if (user.personalInfo != null) {
      try {
        Map<String, dynamic> personalInfoJson;
        if (user.personalInfo is Map) {
          personalInfoJson = Map<String, dynamic>.from(user.personalInfo as Map);
        } else {
          final personalInfoStr = user.personalInfo.toString();
          personalInfoJson = jsonDecode(personalInfoStr);
        }
        if (personalInfoJson['specifications'] != null) {
          final specs = extractSpecs(personalInfoJson['specifications']);
          if (hasProductionSubcategory(specs)) {
            return true;
          }
        }
        if (personalInfoJson['specification'] != null) {
          final specs = extractSpecs(personalInfoJson['specification']);
          if (hasProductionSubcategory(specs)) {
            return true;
          }
        }
      } catch (_) {
        // If not JSON, check if string contains any subcategory
        final specs = extractSpecs(user.personalInfo);
        if (hasProductionSubcategory(specs)) {
          return true;
        }
      }
    }

    // 3. Check roles list from new API response
    if (user.profile?.roles != null) {
      final hasProducerRole = user.profile!.roles!.any((r) {
        final role = (r['role'] ?? '').toString().toLowerCase();
        return productionSubcategories.any(
              (subcategory) => role.contains(subcategory),
            ) ||
            role.contains('company');
      });
      if (hasProducerRole) return true;
    }

    return false;
  }

  static String? getUserSpecification() {
    final UserModel? user = UserHelper.userNotifier.value;
    return user?.profile?.specification;
  }

  static void checkLoggedIn(BuildContext context, VoidCallback onLoggedIn) {
    if (UserHelper.userNotifier.value != null) {
      onLoggedIn();
    } else {
      context.pushNamed(Routes.login);
    }
  }
}
