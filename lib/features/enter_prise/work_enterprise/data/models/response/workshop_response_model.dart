class WorkshopResponseModel {
  final int id;
  final String name;
  final String description;
  final String? coverImage;
  final int? createdBy;
  final String? createdByEmail;
  final String? createdByFullname;
  final String? createdByPhoto;
  final int? createdByRatingCount;
  final double? createdByRatingMean;
  final bool isActive;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String specialization;
  final int numberOfParticipants;
  final bool isApproved;
  final DateTime? approvedAt;
  final int? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationsCount;
  final int approvedApplicationsCount;
  final MyRegistration? myRegistration;

  WorkshopResponseModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    this.createdBy,
    this.createdByEmail,
    this.createdByFullname,
    this.createdByPhoto,
    this.createdByRatingCount,
    this.createdByRatingMean,
    required this.isActive,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.specialization,
    required this.numberOfParticipants,
    required this.isApproved,
    this.approvedAt,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.applicationsCount,
    required this.approvedApplicationsCount,
    this.myRegistration,
  });

  factory WorkshopResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkshopResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image']?.toString(),
      createdBy: json['created_by'],
      createdByEmail: json['created_by_email'],
      createdByFullname: json['created_by_fullname'],
      createdByPhoto: json['created_by_photo']?.toString(),
      createdByRatingCount: json['created_by_rating_count'] is int ? json['created_by_rating_count'] : (json['created_by_rating_count'] is String ? int.tryParse(json['created_by_rating_count']) : null),
      createdByRatingMean: json['created_by_rating_mean'] is double ? json['created_by_rating_mean'] : (json['created_by_rating_mean'] is num ? json['created_by_rating_mean'].toDouble() : (json['created_by_rating_mean'] is String ? double.tryParse(json['created_by_rating_mean']) : null)),
      isActive: json['is_active'] ?? false,
      location: json['location'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      specialization: json['specialization'] ?? '',
      numberOfParticipants: json['number_of_participants'] ?? 0,
      isApproved: json['is_approved'] ?? false,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      approvedBy: json['approved_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      applicationsCount: json['applications_count'] ?? 0,
      approvedApplicationsCount: json['approved_applications_count'] ?? 0,
      myRegistration: json['my_registration'] != null
          ? MyRegistration.fromJson(json['my_registration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage ?? '',
      'created_by': createdBy,
      'created_by_email': createdByEmail,
      'created_by_fullname': createdByFullname,
      'created_by_photo': createdByPhoto,
      'created_by_rating_count': createdByRatingCount,
      'created_by_rating_mean': createdByRatingMean,
      'is_active': isActive,
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'specialization': specialization,
      'number_of_participants': numberOfParticipants,
      'is_approved': isApproved,
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'applications_count': applicationsCount,
      'approved_applications_count': approvedApplicationsCount,
      'my_registration': myRegistration?.toJson(),
    };
  }
}

class MyRegistration {
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

  MyRegistration({
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

  factory MyRegistration.fromJson(Map<String, dynamic> json) {
    return MyRegistration(
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
}

