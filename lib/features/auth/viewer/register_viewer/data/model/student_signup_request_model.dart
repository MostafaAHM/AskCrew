import 'dart:io';

class StudentSignupRequestModel {
  final String fullname;
  final String email;
  final String mobilePhone;
  final String password;
  final String institute;
  final String specification;
  final String academicYear;
  final String skills;
  final String country;
  final String city;
  final File? cv; // CV file (will be converted to MultipartFile for upload)
  final String? facebookLink;
  final String? instagramLink;
  final String? linkedinLink;
  final String? youtubeLink;
  final String planId; // Subscription plan ID
  final List<File>?
  videos; // Optional list of video files (will be converted to MultipartFile for upload)
  final List<File>?
  images; // Optional list of image files (will be converted to MultipartFile for upload)

  StudentSignupRequestModel({
    required this.fullname,
    required this.email,
    required this.mobilePhone,
    required this.password,
    required this.institute,
    required this.specification,
    required this.academicYear,
    required this.skills,
    required this.country,
    required this.city,
    this.cv,
    this.facebookLink,
    this.instagramLink,
    this.linkedinLink,
    this.youtubeLink,
    required this.planId,
    this.videos,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'mobile_phone': mobilePhone,
      'password': password,
      'institute': institute,
      'specification': specification,
      'academic_year': academicYear,
      'skills': skills,
      'country': country,
      'city': city,
      if (facebookLink != null && facebookLink!.isNotEmpty)
        'facebook_link': facebookLink,
      if (instagramLink != null && instagramLink!.isNotEmpty)
        'instagram_link': instagramLink,
      if (linkedinLink != null && linkedinLink!.isNotEmpty)
        'linkedin_link': linkedinLink,
      if (youtubeLink != null && youtubeLink!.isNotEmpty)
        'youtube_link': youtubeLink,
      'plan_id': planId,
      // Note: cv, videos, and images are File objects and should be sent as MultipartFile
      // in multipart/form-data request, not included in JSON
    };
  }
}
