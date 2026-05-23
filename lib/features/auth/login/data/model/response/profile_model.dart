import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final List<dynamic> favoriteCategories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic specification;
  final int? id;
  final String? institute;
  final String? academicYear;
  final dynamic skills;
  final String? country;
  final String? city;
  final String? cv;
  final String? facebookLink;
  final String? instagramLink;
  final String? linkedinLink;
  final String? youtubeLink;
  final String? paymentPlan;
  final bool? isActivatedByAdmin;
  final bool? isAvailable;
  final Map<String, dynamic>? plan;
  // Enterprise profile fields
  final String? experience;
  final List<Map<String, String>>? images;
  final List<Map<String, String>>? videos;
  final int? views;
  final int? totalBookings;
  final int? topWorkView;
  // Student profile fields
  final int? jobApplicationsCount;
  final int? approvedJobApplicationsCount;
  final List<dynamic>? roles;
  final String? experienceLevel;
  final List<String>? portfolioLinks;

  const ProfileModel({
    required this.favoriteCategories,
    required this.createdAt,
    required this.updatedAt,
    this.specification,
    this.id,
    this.institute,
    this.academicYear,
    this.skills,
    this.country,
    this.city,
    this.cv,
    this.facebookLink,
    this.instagramLink,
    this.linkedinLink,
    this.youtubeLink,
    this.paymentPlan,
    this.isActivatedByAdmin,
    this.isAvailable,
    this.plan,
    this.experience,
    this.images,
    this.videos,
    this.views,
    this.totalBookings,
    this.topWorkView,
    this.jobApplicationsCount,
    this.approvedJobApplicationsCount,
    this.roles,
    this.experienceLevel,
    this.portfolioLinks,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse images list
    List<Map<String, String>>? imagesList;
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((item) {
            if (item is Map) {
              return Map<String, String>.from(
                item.map((k, v) => MapEntry(k.toString(), v.toString())),
              );
            }
            return <String, String>{};
          })
          .where((map) => map.isNotEmpty)
          .toList();
    }

    // Parse videos list
    List<Map<String, String>>? videosList;
    if (json['videos'] != null && json['videos'] is List) {
      videosList = (json['videos'] as List)
          .map((item) {
            if (item is Map) {
              return Map<String, String>.from(
                item.map((k, v) => MapEntry(k.toString(), v.toString())),
              );
            }
            return <String, String>{};
          })
          .where((map) => map.isNotEmpty)
          .toList();
    }

    // Parse plan safely — JSON maps often arrive as Map<dynamic,dynamic>
    Map<String, dynamic>? planMap;
    if (json['plan'] is Map) {
      planMap = Map<String, dynamic>.from(json['plan'] as Map);
    }

    // Parse roles safely
    List<dynamic>? rolesList;
    if (json['roles'] is List) {
      rolesList = (json['roles'] as List).map((item) {
        if (item is Map) return Map<String, dynamic>.from(item);
        return item;
      }).toList();
    }

    return ProfileModel(
      id: json['id'],
      favoriteCategories: json['favorite_categories'] is List
          ? json['favorite_categories']
          : [],
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] is String
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      specification: json['specification'] is String
          ? json['specification']
          : (json['specification'] != null
                ? json['specification'].toString()
                : null),
      institute: json['institute'] is String ? json['institute'] : null,
      academicYear: json['academic_year'] is String
          ? json['academic_year']
          : null,
      skills: json['skills'] is String
          ? json['skills']
          : (json['skills'] != null ? json['skills'].toString() : null),
      country: json['country'] is String ? json['country'] : null,
      city: json['city'] is String ? json['city'] : null,
      cv: json['cv'] is String ? json['cv'] : null,
      facebookLink: json['facebook_link'] is String
          ? json['facebook_link']
          : null,
      instagramLink: json['instagram_link'] is String
          ? json['instagram_link']
          : null,
      linkedinLink: json['linkedin_link'] is String
          ? json['linkedin_link']
          : null,
      youtubeLink: json['youtube_link'] is String ? json['youtube_link'] : null,
      paymentPlan: json['payment_plan'] is String ? json['payment_plan'] : null,
      isActivatedByAdmin: json['is_activated_by_admin'],
      isAvailable: json['is_available'] is bool
          ? json['is_available']
          : (json['is_available'] == 'true'),
      plan: planMap,
      experience: json['experience'] is String ? json['experience'] : null,
      images: imagesList,
      videos: videosList,
      views: json['views'] is int
          ? json['views']
          : (json['views'] is String ? int.tryParse(json['views']) : null),
      totalBookings: json['total_bookings'] is int
          ? json['total_bookings']
          : (json['total_bookings'] is String
                ? int.tryParse(json['total_bookings'])
                : null),
      topWorkView: json['top_work_view'] is int
          ? json['top_work_view']
          : (json['top_work_view'] is String
                ? int.tryParse(json['top_work_view'])
                : null),
      jobApplicationsCount: json['job_applications_count'] is int
          ? json['job_applications_count']
          : (json['job_applications_count'] is String
                ? int.tryParse(json['job_applications_count'])
                : null),
      approvedJobApplicationsCount:
          json['approved_job_applications_count'] is int
          ? json['approved_job_applications_count']
          : (json['approved_job_applications_count'] is String
                ? int.tryParse(json['approved_job_applications_count'])
                : null),
      roles: rolesList,
      experienceLevel: json['experience_level'] is String
          ? json['experience_level']
          : null,
      portfolioLinks: json['portfolio_links'] is List
          ? List<String>.from(json['portfolio_links'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favorite_categories': favoriteCategories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'specification': specification,
      'institute': institute,
      'academic_year': academicYear,
      'skills': skills,
      'country': country,
      'city': city,
      'cv': cv,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'linkedin_link': linkedinLink,
      'youtube_link': youtubeLink,
      'payment_plan': paymentPlan,
      'is_activated_by_admin': isActivatedByAdmin,
      'is_available': isAvailable,
      'plan': plan,
      'experience': experience,
      'images': images,
      'videos': videos,
      'views': views,
      'total_bookings': totalBookings,
      'top_work_view': topWorkView,
      'job_applications_count': jobApplicationsCount,
      'approved_job_applications_count': approvedJobApplicationsCount,
      'roles': roles,
      'experience_level': experienceLevel,
      'portfolio_links': portfolioLinks,
    };
  }

  ProfileModel copyWith({
    List<dynamic>? favoriteCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic specification,
    int? id,
    String? institute,
    String? academicYear,
    dynamic skills,
    String? country,
    String? city,
    String? cv,
    String? facebookLink,
    String? instagramLink,
    String? linkedinLink,
    String? youtubeLink,
    String? paymentPlan,
    bool? isActivatedByAdmin,
    bool? isAvailable,
    Map<String, dynamic>? plan,
    String? experience,
    List<Map<String, String>>? images,
    List<Map<String, String>>? videos,
    int? views,
    int? totalBookings,
    int? topWorkView,
    int? jobApplicationsCount,
    int? approvedJobApplicationsCount,
    List<dynamic>? roles,
    String? experienceLevel,
    List<String>? portfolioLinks,
  }) {
    return ProfileModel(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specification: specification ?? this.specification,
      id: id ?? this.id,
      institute: institute ?? this.institute,
      academicYear: academicYear ?? this.academicYear,
      skills: skills ?? this.skills,
      country: country ?? this.country,
      city: city ?? this.city,
      cv: cv ?? this.cv,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      linkedinLink: linkedinLink ?? this.linkedinLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      isActivatedByAdmin: isActivatedByAdmin ?? this.isActivatedByAdmin,
      isAvailable: isAvailable ?? this.isAvailable,
      plan: plan ?? this.plan,
      experience: experience ?? this.experience,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      views: views ?? this.views,
      totalBookings: totalBookings ?? this.totalBookings,
      topWorkView: topWorkView ?? this.topWorkView,
      jobApplicationsCount: jobApplicationsCount ?? this.jobApplicationsCount,
      approvedJobApplicationsCount:
          approvedJobApplicationsCount ?? this.approvedJobApplicationsCount,
      roles: roles ?? this.roles,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
    );
  }

  @override
  List<Object?> get props => [
    favoriteCategories,
    createdAt,
    updatedAt,
    specification,
    id,
    institute,
    academicYear,
    skills,
    country,
    city,
    cv,
    facebookLink,
    instagramLink,
    linkedinLink,
    youtubeLink,
    paymentPlan,
    isActivatedByAdmin,
    plan,
    experience,
    images,
    videos,
    views,
    totalBookings,
    topWorkView,
    jobApplicationsCount,
    approvedJobApplicationsCount,
    roles,
  ];
}
