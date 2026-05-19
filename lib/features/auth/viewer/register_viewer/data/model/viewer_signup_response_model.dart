import 'package:equatable/equatable.dart';

class ViewerProfileModel extends Equatable {
  final List<String> favoriteCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ViewerProfileModel({
    required this.favoriteCategories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ViewerProfileModel.fromJson(Map<String, dynamic> json) {
    return ViewerProfileModel(
      favoriteCategories: json['favorite_categories'] != null
          ? List<String>.from(json['favorite_categories'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorite_categories': favoriteCategories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [favoriteCategories, createdAt, updatedAt];
}

class ViewerSignupResponseModel extends Equatable {
  final String message;
  final int id;
  final String email;
  final String fullname;
  final String mobilePhone;
  final String wallet;
  final int points;
  final String? profilePhoto;
  final Map<String, dynamic>? personalInfo;
  final bool isVerified;
  final bool isActive;
  final String type;
  final DateTime dateJoined;
  final ViewerProfileModel profile;

  const ViewerSignupResponseModel({
    required this.message,
    required this.id,
    required this.email,
    required this.fullname,
    required this.mobilePhone,
    required this.wallet,
    required this.points,
    this.profilePhoto,
    this.personalInfo,
    required this.isVerified,
    required this.isActive,
    required this.type,
    required this.dateJoined,
    required this.profile,
  });

  factory ViewerSignupResponseModel.fromJson(Map<String, dynamic> json) {
    return ViewerSignupResponseModel(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      wallet: json['wallet'] ?? '0.00',
      points: json['points'] ?? 0,
      profilePhoto: json['profile_photo'],
      personalInfo: json['personal_info'] != null
          ? Map<String, dynamic>.from(json['personal_info'])
          : null,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      type: json['type'] ?? 'viewer',
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
      profile: json['profile'] != null
          ? ViewerProfileModel.fromJson(json['profile'])
          : ViewerProfileModel(
              favoriteCategories: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'id': id,
      'email': email,
      'fullname': fullname,
      'mobile_phone': mobilePhone,
      'wallet': wallet,
      'points': points,
      'profile_photo': profilePhoto,
      'personal_info': personalInfo,
      'is_verified': isVerified,
      'is_active': isActive,
      'type': type,
      'date_joined': dateJoined.toIso8601String(),
      'profile': profile.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    message,
    id,
    email,
    fullname,
    mobilePhone,
    wallet,
    points,
    profilePhoto,
    personalInfo,
    isVerified,
    isActive,
    type,
    dateJoined,
    profile,
  ];
}
