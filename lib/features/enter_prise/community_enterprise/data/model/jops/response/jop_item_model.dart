class JobItemModel {
  final int id;
  final String companyName;
  final String jobTitle;
  final String? image;
  final String about;
  final bool isActive;
  final int author;
  final String authorName;
  final String authorSpecification;
  final int applicationsCount;
  final bool applied;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobItemModel({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.image,
    required this.about,
    required this.isActive,
    required this.author,
    required this.authorName,
    required this.authorSpecification,
    required this.applicationsCount,
    required this.applied,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobItemModel.fromJson(Map<String, dynamic> json) {
    return JobItemModel(
      id: json['id'],
      companyName: json['company_name'] ?? '',
      jobTitle: json['job_title'] ?? '',
      image: json['image'],
      about: json['about'] ?? '',
      isActive: json['is_active'] ?? false,
      author: json['author'] ?? 0,
      authorName: json['author_name'] ?? '',
      authorSpecification: json['author_specification'] ?? '',
      applicationsCount: json['applications_count'] ?? 0,
      applied: json['applied'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
