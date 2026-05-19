import 'dart:io';

class EnterpriseSignupRequestModel {
  final String fullname;
  final String email;
  final String mobilePhone;
  final String password;
  final String
  specification; // Specification ID (can be comma-separated if multiple)
  final String experience; // Experience level ID
  final String country;
  final String city;
  final String planId; // Subscription plan ID
  final List<File>?
  videos; // Optional list of video files (will be converted to MultipartFile for upload)
  final List<String>?
  images; // Optional list of image file paths (will be converted to MultipartFile for upload)

  EnterpriseSignupRequestModel({
    required this.fullname,
    required this.email,
    required this.mobilePhone,
    required this.password,
    required this.specification,
    required this.experience,
    required this.country,
    required this.city,
    required this.planId,
    this.videos,
    this.images,
  });

  /// Factory constructor to create from a list of specification IDs
  factory EnterpriseSignupRequestModel.fromSpecificationList({
    required String fullname,
    required String email,
    required String mobilePhone,
    required String password,
    required List<String> specificationIds, // List of specification IDs
    required String experience,
    required String country,
    required String city,
    required String planId,
    List<File>? videos,
    List<String>? images,
  }) {
    return EnterpriseSignupRequestModel(
      fullname: fullname,
      email: email,
      mobilePhone: mobilePhone,
      password: password,
      specification: specificationIds.join(','), // Join multiple IDs with comma
      experience: experience,
      country: country,
      city: city,
      planId: planId,
      videos: videos,
      images: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'mobile_phone': mobilePhone,
      'password': password,
      'specification': specification,
      'experience': experience,
      'country': country,
      'city': city,
      'plan_id': planId,
      // Note: videos and images are File objects and should be sent as MultipartFile
      // in multipart/form-data request, not included in JSON
      if (images != null && images!.isNotEmpty) 'images': images,
    };
  }
}
