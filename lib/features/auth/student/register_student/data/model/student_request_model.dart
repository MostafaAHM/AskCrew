import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';

class StudentRequestModel {
  final String email;
  final String password;
  final String fullname;
  final String mobilePhone;
  final String institute;
  final String specification;
  final String academicYear;
  final String skills;
  final String country;
  final String city;
  final String planId;

  final File? cv;
  final List<File>? videos;
  final List<File>? images;
  final File? profilePhoto;

  final String facebookLink;
  final String instagramLink;
  final String linkedinLink;
  final String youtubeLink;

  final String? personalInfo;
  final int? durationMonths;
  final List<String>? roles;
  final String? rolesContentType;
  final int? rolesObjectId;
  final List<SelectedWorkItem>? workItemsRoles;
  final String? emailAddress;
  final String? experienceLevel;
  final List<String>? portfolioLinks;

  StudentRequestModel({
    required this.email,
    required this.password,
    required this.fullname,
    required this.mobilePhone,
    required this.institute,
    required this.specification,
    required this.academicYear,
    required this.skills,
    required this.country,
    required this.city,
    required this.planId,
    required this.facebookLink,
    required this.instagramLink,
    required this.linkedinLink,
    required this.youtubeLink,
    this.cv,
    this.videos,
    this.images,
    this.profilePhoto,
    this.personalInfo,
    this.durationMonths,
    this.roles,
    this.rolesContentType,
    this.rolesObjectId,
    this.workItemsRoles,
    this.emailAddress,
    this.experienceLevel,
    this.portfolioLinks,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'fullname': fullname,
      'mobile_phone': mobilePhone,
      'institute': institute,
      'specification': specification,
      'academic_year': academicYear,
      'skills': skills,
      'country': country,
      'city': city,
      'plan_id': planId,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'linkedin_link': linkedinLink,
      'youtube_link': youtubeLink,
      if (personalInfo != null) 'personal_info': personalInfo,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (emailAddress != null) 'email_address': emailAddress,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (portfolioLinks != null) 'portfolio_links': portfolioLinks,
    };

    if (workItemsRoles != null && workItemsRoles!.isNotEmpty) {
      final rolesList = workItemsRoles!
          .map((item) => item.toRoleMap())
          .toList();
      map['roles'] = jsonEncode(rolesList);
    } else if (roles != null) {
      final rolesList = roles!
          .map(
            (role) => {
              if (rolesContentType != null) 'content_type': rolesContentType,
              if (rolesObjectId != null) 'content_id': rolesObjectId,
              'role': role,
            },
          )
          .toList();
      map['roles'] = jsonEncode(rolesList);
    }

    return map;
  }

  Future<FormData> toFormData() async {
    final formDataMap = toJson();

    if (cv != null) {
      formDataMap["cv"] = await MultipartFile.fromFile(
        cv!.path,
        filename: cv!.path.split('/').last,
      );
    }

    if (videos != null && videos!.isNotEmpty) {
      formDataMap["videos"] = await Future.wait(
        videos!.map(
          (v) async => await MultipartFile.fromFile(
            v.path,
            filename: v.path.split('/').last,
          ),
        ),
      );
    }

    if (images != null && images!.isNotEmpty) {
      formDataMap["images"] = await Future.wait(
        images!.map(
          (img) async => await MultipartFile.fromFile(
            img.path,
            filename: img.path.split('/').last,
          ),
        ),
      );
    }

    if (profilePhoto != null) {
      formDataMap['profile_photo'] = await MultipartFile.fromFile(
        profilePhoto!.path,
        filename: profilePhoto!.path.split('/').last,
      );
    }

    if (workItemsRoles != null && workItemsRoles!.isNotEmpty) {
      formDataMap['roles'] = jsonEncode(
        workItemsRoles!.map((item) => item.toRoleMap()).toList(),
      );
    } else if (roles != null) {
      final rolesList = roles!
          .map(
            (role) => {
              if (rolesContentType != null) 'content_type': rolesContentType,
              if (rolesObjectId != null) 'content_id': rolesObjectId,
              'role': role,
            },
          )
          .toList();
      formDataMap['roles'] = jsonEncode(rolesList);
    }

    return FormData.fromMap(formDataMap);
  }

  /// FormData for complete profile (swap mode) - without email, password, mobile_phone, fullname
  Future<FormData> toCompleteProfileFormData() async {
    final formDataMap = {
      "Name": fullname,
      "institute": institute,
      "specification": specification,
      "academic_year": academicYear,
      "skills": skills,
      "country": country,
      "city": city,
      "plan_id": planId,
      "facebook_link": facebookLink,
      "instagram_link": instagramLink,
      "linkedin_link": linkedinLink,
      "youtube_link": youtubeLink,
      if (personalInfo != null) 'personal_info': personalInfo,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (emailAddress != null) 'email_address': emailAddress,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (portfolioLinks != null) 'portfolio_links': portfolioLinks,
    };

    if (cv != null) {
      formDataMap["cv"] = await MultipartFile.fromFile(
        cv!.path,
        filename: cv!.path.split('/').last,
      );
    }

    if (videos != null && videos!.isNotEmpty) {
      formDataMap["videos"] = await Future.wait(
        videos!.map(
          (v) async => await MultipartFile.fromFile(
            v.path,
            filename: v.path.split('/').last,
          ),
        ),
      );
    }

    if (images != null && images!.isNotEmpty) {
      formDataMap["images"] = await Future.wait(
        images!.map(
          (img) async => await MultipartFile.fromFile(
            img.path,
            filename: img.path.split('/').last,
          ),
        ),
      );
    }

    if (profilePhoto != null) {
      formDataMap['profile_photo'] = await MultipartFile.fromFile(
        profilePhoto!.path,
        filename: profilePhoto!.path.split('/').last,
      );
    }

    if (workItemsRoles != null && workItemsRoles!.isNotEmpty) {
      formDataMap['roles'] = jsonEncode(
        workItemsRoles!.map((item) => item.toRoleMap()).toList(),
      );
    } else if (roles != null) {
      final rolesList = roles!
          .map(
            (role) => {
              if (rolesContentType != null) 'content_type': rolesContentType,
              if (rolesObjectId != null) 'content_id': rolesObjectId,
              'role': role,
            },
          )
          .toList();
      formDataMap['roles'] = jsonEncode(rolesList);
    }

    return FormData.fromMap(formDataMap);
  }
}
