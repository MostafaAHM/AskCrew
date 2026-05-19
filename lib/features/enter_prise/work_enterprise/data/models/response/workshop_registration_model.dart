import 'package:equatable/equatable.dart';

class WorkshopRegistrationModel extends Equatable {
  final int id;
  final int workshop;
  final int user;
  final String userEmail;
  final String userFullname;
  final String? userPhoto;
  final int? userRatingCount;
  final double? userRatingMean;
  final DateTime registrationDate;
  final String status;

  const WorkshopRegistrationModel({
    required this.id,
    required this.workshop,
    required this.user,
    required this.userEmail,
    required this.userFullname,
    this.userPhoto,
    this.userRatingCount,
    this.userRatingMean,
    required this.registrationDate,
    required this.status,
  });

  factory WorkshopRegistrationModel.fromJson(Map<String, dynamic> json) {
    return WorkshopRegistrationModel(
      id: json['id'] ?? 0,
      workshop: json['workshop'] ?? 0,
      user: json['user'] ?? 0,
      userEmail: json['user_email'] ?? '',
      userFullname: json['user_fullname'] ?? '',
      userPhoto: json['user_photo']?.toString(),
      userRatingCount: json['user_rating_count'] is int ? json['user_rating_count'] : (json['user_rating_count'] is String ? int.tryParse(json['user_rating_count']) : null),
      userRatingMean: json['user_rating_mean'] is double ? json['user_rating_mean'] : (json['user_rating_mean'] is num ? json['user_rating_mean'].toDouble() : (json['user_rating_mean'] is String ? double.tryParse(json['user_rating_mean']) : null)),
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop': workshop,
      'user': user,
      'user_email': userEmail,
      'user_fullname': userFullname,
      'user_photo': userPhoto,
      'user_rating_count': userRatingCount,
      'user_rating_mean': userRatingMean,
      'registration_date': registrationDate.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        workshop,
        user,
        userEmail,
        userFullname,
        userPhoto,
        userRatingCount,
        userRatingMean,
        registrationDate,
        status,
      ];
}

