class StudentProfileModel {
  final String id;
  final String name;
  final String profession;
  final String profileImage;
  final bool isVerified;
  final bool waterMark;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;
  final List<String>? images; // Profile images URLs
  final int views;
  final int jobApplicationsCount;
  final int approvedJobApplicationsCount;

  const StudentProfileModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.profileImage,
    this.isVerified = false,
    this.waterMark = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isAvailable = false,
    this.images,
    this.views = 0,
    this.jobApplicationsCount = 0,
    this.approvedJobApplicationsCount = 0,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      profileImage: json['profileImage'] ?? '',
      isVerified: json['isVerified'] ?? false,
      waterMark: json['water_mark'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      views: json['views'] is int
          ? json['views']
          : (json['views'] is String
                ? int.tryParse(json['views'] ?? '0') ?? 0
                : 0),
      jobApplicationsCount: json['job_applications_count'] is int
          ? json['job_applications_count']
          : (json['job_applications_count'] is String
                ? int.tryParse(json['job_applications_count'] ?? '0') ?? 0
                : 0),
      approvedJobApplicationsCount:
          json['approved_job_applications_count'] is int
          ? json['approved_job_applications_count']
          : (json['approved_job_applications_count'] is String
                ? int.tryParse(
                        json['approved_job_applications_count'] ?? '0',
                      ) ??
                      0
                : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'water_mark': waterMark,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isAvailable': isAvailable,
      'images': images,
      'views': views,
      'job_applications_count': jobApplicationsCount,
      'approved_job_applications_count': approvedJobApplicationsCount,
    };
  }
}
