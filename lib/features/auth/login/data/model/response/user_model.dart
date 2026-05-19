import 'package:equatable/equatable.dart';
import 'profile_model.dart';

class UserModel extends Equatable {
  final int id;
  final String email;
  final String fullname;
  final String mobilePhone;
  final String wallet;
  final int points;
  final String? profilePhoto;
  final dynamic personalInfo;
  final bool isVerified;
  final bool waterMark;
  final bool isActive;
  final String type;
  final int typeInt;
  final DateTime dateJoined;
  final ProfileModel? profile;
  final int? ratingCount;
  final double? ratingMean;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullname,
    required this.mobilePhone,
    required this.wallet,
    required this.points,
    this.profilePhoto,
    this.personalInfo,
    required this.isVerified,
    this.waterMark = false,
    required this.isActive,
    required this.type,
    required this.typeInt,
    required this.dateJoined,
    this.profile,
    this.ratingCount,
    this.ratingMean,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      wallet: json['wallet'] ?? '0.00',
      points: json['points'] ?? 0,
      profilePhoto: json['profile_photo'],
      personalInfo: json['personal_info'],
      isVerified: json['is_verified'] ?? false,
      waterMark: json['water_mark'] ?? false,
      isActive: json['is_active'] ?? false,
      type: json['type'] ?? '',
      typeInt: json['type_int'] ?? 0,
      dateJoined: DateTime.parse(json['date_joined']),
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      ratingCount: json['rating_count'] is int
          ? json['rating_count']
          : (json['rating_count'] is String
                ? int.tryParse(json['rating_count'])
                : null),
      ratingMean: json['rating_mean'] is double
          ? json['rating_mean']
          : (json['rating_mean'] is num
                ? json['rating_mean'].toDouble()
                : (json['rating_mean'] is String
                      ? double.tryParse(json['rating_mean'])
                      : null)),
    );
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? fullname,
    String? mobilePhone,
    String? wallet,
    int? points,
    String? profilePhoto,
    dynamic personalInfo,
    bool? isVerified,
    bool? waterMark,
    bool? isActive,
    String? type,
    int? typeInt,
    DateTime? dateJoined,
    ProfileModel? profile,
    int? ratingCount,
    double? ratingMean,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      wallet: wallet ?? this.wallet,
      points: points ?? this.points,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      personalInfo: personalInfo ?? this.personalInfo,
      isVerified: isVerified ?? this.isVerified,
      waterMark: waterMark ?? this.waterMark,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      typeInt: typeInt ?? this.typeInt,
      dateJoined: dateJoined ?? this.dateJoined,
      profile: profile ?? this.profile,
      ratingCount: ratingCount ?? this.ratingCount,
      ratingMean: ratingMean ?? this.ratingMean,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullname': fullname,
      'mobile_phone': mobilePhone,
      'wallet': wallet,
      'points': points,
      'profile_photo': profilePhoto,
      'personal_info': personalInfo,
      'is_verified': isVerified,
      'water_mark': waterMark,
      'is_active': isActive,
      'type': type,
      'type_int': typeInt,
      'date_joined': dateJoined.toIso8601String(),
      'profile': profile?.toJson(),
      'rating_count': ratingCount,
      'rating_mean': ratingMean,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullname,
    mobilePhone,
    wallet,
    points,
    profilePhoto,
    personalInfo,
    isVerified,
    waterMark,
    isActive,
    type,
    typeInt,
    dateJoined,
    profile,
    ratingCount,
    ratingMean,
  ];
}
