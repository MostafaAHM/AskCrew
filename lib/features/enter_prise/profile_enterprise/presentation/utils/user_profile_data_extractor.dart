import 'dart:convert';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';

class UserProfileDataExtractor {
  static Map<String, dynamic> extractPersonalInfo(UserModel? userData) {
    Map<String, dynamic> personalInfoMap = {};

    if (userData?.personalInfo != null) {
      if (userData!.personalInfo is String) {
        try {
          personalInfoMap =
              jsonDecode(userData.personalInfo as String)
                  as Map<String, dynamic>;
        } catch (e) {
          if (userData.personalInfo is Map) {
            personalInfoMap = userData.personalInfo as Map<String, dynamic>;
          }
        }
      } else if (userData.personalInfo is Map) {
        personalInfoMap = userData.personalInfo as Map<String, dynamic>;
      }
    }

    return personalInfoMap;
  }

  static String extractUserName(
    UserModel? userData,
    Map<String, dynamic> personalInfoMap,
  ) {
    return userData?.fullname ?? '';
  }

  static String extractUserSpecification(
    UserModel? userData,
    Map<String, dynamic> personalInfoMap,
  ) {
    final spec = userData?.profile?.specification;
    if (spec == null) {
      return personalInfoMap['selectedWork']?.toString() ?? '';
    }
    if (spec is String) return spec;
    if (spec is Map) {
      final values = spec.values.whereType<String>();
      return values.isNotEmpty
          ? values.join(', ')
          : (personalInfoMap['selectedWork']?.toString() ?? '');
    }
    return spec.toString();
  }

  static String? extractAboutText(Map<String, dynamic> personalInfoMap) {
    final aboutText = personalInfoMap['personalInfo']?.toString();
    return aboutText != null && aboutText.trim().isNotEmpty ? aboutText : null;
  }

  static String? extractLocation(Map<String, dynamic> personalInfoMap) {
    if (personalInfoMap['city'] != null && personalInfoMap['country'] != null) {
      return '${personalInfoMap['city']}, ${personalInfoMap['country']}';
    }
    final city = personalInfoMap['city']?.toString();
    final country = personalInfoMap['country']?.toString();
    if (city != null && city.trim().isNotEmpty) return city;
    if (country != null && country.trim().isNotEmpty) return country;
    return null;
  }

  static String? extractEducation(Map<String, dynamic> personalInfoMap) {
    if (personalInfoMap['institutes'] != null &&
        personalInfoMap['institutes'] is List) {
      final institutes = personalInfoMap['institutes'] as List;
      if (institutes.isNotEmpty) {
        final instituteName = institutes[0]['name']?.toString() ?? '';
        final gradYear = personalInfoMap['graduatedYear']?.toString();
        if (instituteName.isNotEmpty) {
          return gradYear != null && gradYear.isNotEmpty
              ? '$instituteName (Grad $gradYear)'
              : instituteName;
        }
      }
    }
    return null;
  }

  static List<String> extractSkills(dynamic skillsData) {
    final List<String> result = [];
    if (skillsData == null) return result;
    if (skillsData is List) {
      for (final item in skillsData) {
        result.add(item.toString());
      }
      return result;
    }
    if (skillsData is Map) {
      for (final value in skillsData.values) {
        result.add(value.toString());
      }
      return result;
    }
    final skillsString = skillsData.toString();
    if (skillsString.trim().isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(skillsString);
      for (final item in jsonList) {
        result.add(item.toString());
      }
    } catch (_) {
      final parts = skillsString.split(',');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty) {
          result.add(trimmed);
        }
      }
    }
    return result;
  }

  static String? extractCvName(Map<String, dynamic> personalInfoMap) {
    final cvPath = personalInfoMap['cvPath']?.toString();
    return cvPath != null && cvPath.isNotEmpty ? cvPath.split('/').last : null;
  }

  static String? extractCvPath(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['cvPath']?.toString();
  }

  static String? extractFacebookLink(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['facebookLink']?.toString();
  }

  static String? extractInstagramLink(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['instagramLink']?.toString();
  }

  static String? extractLinkedinLink(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['linkedinLink']?.toString();
  }

  static String? extractEmailLink(
    UserModel? userData,
    Map<String, dynamic> personalInfoMap,
  ) {
    return personalInfoMap['emailAddress']?.toString() ?? userData?.email;
  }

  static String? extractYoutubeLink(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['youtubeLink']?.toString();
  }

  static List<String> extractPortfolioLinks(
    Map<String, dynamic> personalInfoMap,
  ) {
    if (personalInfoMap['portfolioLinks'] != null &&
        personalInfoMap['portfolioLinks'] is List) {
      return List<String>.from(personalInfoMap['portfolioLinks']);
    }
    return [];
  }

  static String? extractExperienceLevel(Map<String, dynamic> personalInfoMap) {
    return personalInfoMap['experienceLevel']?.toString();
  }

  static String? extractRawPersonalInfo(UserModel? userData) {
    if (userData?.personalInfo is String) {
      final s = userData!.personalInfo as String;
      if (s.isNotEmpty && !s.startsWith('{')) return s;
    }
    return null;
  }
}
