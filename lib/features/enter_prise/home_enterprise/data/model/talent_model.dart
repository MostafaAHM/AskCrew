import '../../../../auth/login/data/model/response/user_model.dart';

class TalentModel {
  final String id;
  final String name;
  final String role;
  final String specialization;
  final String? imageUrl;
  final bool isVerified;
  final bool waterMark;
  final double rating;
  final bool isAvailable;

  const TalentModel({
    required this.id,
    required this.name,
    required this.role,
    this.specialization = '',
    this.imageUrl,
    this.isVerified = false,
    this.waterMark = false,
    this.rating = 0.0,
    this.isAvailable = false,
  });

  static String? _specToString(dynamic spec) {
    if (spec == null) return null;
    if (spec is String) return spec;
    if (spec is Map) {
      final values = spec.values.whereType<String>();
      return values.isNotEmpty ? values.join(', ') : null;
    }
    return spec.toString();
  }

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['profile'] != null && json['profile']['images'] != null) {
      final images = json['profile']['images'] as List;
      if (images.isNotEmpty && images.first['image'] != null) {
        imageUrl = images.first['image'];
      }
    }

    String role = '';
    if (json['profile'] != null && json['profile']['roles'] != null) {
      final roles = json['profile']['roles'] as List;
      if (roles.isNotEmpty) {
        role = roles.first['role']?.toString() ?? '';
      }
    }
    if (role.isEmpty) {
      role = json['profile']?['category']?.toString() ?? '';
    }

    final specStr = _specToString(json['profile']?['specification']);

    return TalentModel(
      id: json['id']?.toString() ?? '',
      name: json['fullname'] ?? '',
      role: role,
      specialization: specStr ??
          json['profile']?['experience'] ??
          '',
      imageUrl: imageUrl ?? json['profile_photo'],
      isVerified: json['is_verified'] ?? false,
      waterMark: json['water_mark'] ?? false,
      rating: (json['rating_mean'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['profile']?['is_available'] ?? false,
    );
  }

  factory TalentModel.fromUserModel(UserModel user) {
    String role = '';
    if (user.profile?.roles != null && user.profile!.roles!.isNotEmpty) {
      final firstRole = user.profile!.roles!.first;
      if (firstRole is Map && firstRole['role'] != null) {
        role = firstRole['role'].toString();
      } else {
        role = firstRole.toString();
      }
    }

    if (role.isEmpty &&
        user.profile?.favoriteCategories != null &&
        user.profile!.favoriteCategories.isNotEmpty) {
      final firstCategory = user.profile!.favoriteCategories.first;
      if (firstCategory is Map && firstCategory['name'] != null) {
        role = firstCategory['name'].toString();
      } else {
        role = firstCategory.toString();
      }
    }

    String? imageUrl;
    if (user.profile?.images != null && user.profile!.images!.isNotEmpty) {
      imageUrl = user.profile!.images!.first['image'];
    }

    final specStr = _specToString(user.profile?.specification);

    return TalentModel(
      id: user.id.toString(),
      name: user.fullname,
      role: role,
      specialization: specStr ??
          user.profile?.experience ??
          '',
      imageUrl: imageUrl ?? user.profilePhoto,
      isVerified: user.isVerified,
      waterMark: user.waterMark,
      rating: user.ratingMean ?? 0.0,
      isAvailable: user.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': name,
      'profile': {
        'category': role,
        'specification': specialization,
        'images': [
          {'image': imageUrl},
        ],
        'is_available': isAvailable,
      },
      'is_verified': isVerified,
      'water_mark': waterMark,
      'rating_mean': rating,
    };
  }
}
