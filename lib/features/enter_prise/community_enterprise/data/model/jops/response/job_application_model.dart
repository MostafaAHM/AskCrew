class JobApplicationModel {
  final int id;
  final int job;
  final int applicant;
  final String? applicantImage;
  final String applicantName;
  final String jobTitle;
  final String jobCompany;
  final bool isSeen;
  final String status;
  final String createdAt;
  final String updatedAt;

  JobApplicationModel({
    required this.id,
    required this.job,
    required this.applicant,
    this.applicantImage,
    required this.applicantName,
    required this.jobTitle,
    required this.jobCompany,
    required this.isSeen,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as int,
      job: json['job'] as int,
      applicant: json['applicant'] as int,
      applicantImage: json['applicant_image'] as String?,
      applicantName: json['applicant_name'] as String,
      jobTitle: json['job_title'] as String,
      jobCompany: json['job_company'] as String,
      isSeen: json['is_seen'] as bool,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job,
      'applicant': applicant,
      'applicant_image': applicantImage,
      'applicant_name': applicantName,
      'job_title': jobTitle,
      'job_company': jobCompany,
      'is_seen': isSeen,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class JobApplicationsResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<JobApplicationModel> results;

  JobApplicationsResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory JobApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationsResponseModel(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => JobApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
