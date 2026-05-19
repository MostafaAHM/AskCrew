import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../response/enterprise_onboarding_data.dart';

class EnterpriseRequestModel {
  final String fullname;
  final String email;
  final String mobilePhone;
  final String password;
  final String experience;
  final String country;
  final String city;
  final String planId;
  final List<File>? videos;
  final List<File>? images;
  final File? profilePhoto;
  final String? personalInfo;
  final int? durationMonths;
  final List<String>? roles;
  final String? rolesContentType;
  final int? rolesObjectId;
  final List<SelectedWorkItem>? workItemsRoles;

  EnterpriseRequestModel({
    required this.fullname,
    required this.email,
    required this.mobilePhone,
    required this.password,
    required this.experience,
    required this.country,
    required this.city,
    required this.planId,
    this.videos,
    this.images,
    this.profilePhoto,
    this.personalInfo,
    this.durationMonths,
    this.roles,
    this.rolesContentType,
    this.rolesObjectId,
    this.workItemsRoles,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullname': fullname,
      'email': email,
      'mobile_phone': mobilePhone,
      'password': password,
      'experience': experience,
      'country': country,
      'city': city,
      'plan_id': planId,
      if (personalInfo != null) 'personal_info': personalInfo,
      if (durationMonths != null) 'duration_months': durationMonths,
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
    final videoFiles = videos != null
        ? await Future.wait(
            videos!.map(
              (file) async => await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          )
        : null;

    final imageFiles = images != null
        ? await Future.wait(
            images!.map(
              (file) async => await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          )
        : null;

    return FormData.fromMap({
      ...toJson(),
      if (videoFiles != null) 'videos': videoFiles,
      if (imageFiles != null) 'images': imageFiles,
      if (workItemsRoles != null && workItemsRoles!.isNotEmpty)
        'roles': jsonEncode(
          workItemsRoles!.map((item) => item.toRoleMap()).toList(),
        )
      else if (roles != null)
        'roles': jsonEncode(
          roles!
              .map(
                (role) => {
                  if (rolesContentType != null)
                    'content_type': rolesContentType,
                  if (rolesObjectId != null) 'content_id': rolesObjectId,
                  'role': role,
                },
              )
              .toList(),
        ),
      if (profilePhoto != null)
        'profile_photo': await MultipartFile.fromFile(
          profilePhoto!.path,
          filename: profilePhoto!.path.split('/').last,
        ),
    });
  }

  /// FormData for complete profile (swap mode) - without email, password, mobile_phone, fullname
  Future<FormData> toCompleteProfileFormData() async {
    final videoFiles = videos != null
        ? await Future.wait(
            videos!.map(
              (file) async => await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          )
        : null;

    final imageFiles = images != null
        ? await Future.wait(
            images!.map(
              (file) async => await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          )
        : null;

    return FormData.fromMap({
      'Name': fullname,
      'experience': experience,
      'country': country,
      'city': city,
      'plan_id': planId,
      if (personalInfo != null) 'personal_info': personalInfo,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (videoFiles != null) 'videos': videoFiles,
      if (imageFiles != null) 'images': imageFiles,
      if (profilePhoto != null)
        'profile_photo': await MultipartFile.fromFile(
          profilePhoto!.path,
          filename: profilePhoto!.path.split('/').last,
        ),
      if (workItemsRoles != null && workItemsRoles!.isNotEmpty)
        'roles': jsonEncode(
          workItemsRoles!.map((item) => item.toRoleMap()).toList(),
        )
      else if (roles != null)
        'roles': jsonEncode(
          roles!
              .map(
                (role) => {
                  if (rolesContentType != null)
                    'content_type': rolesContentType,
                  if (rolesObjectId != null) 'content_id': rolesObjectId,
                  'role': role,
                },
              )
              .toList(),
        ),
    });
  }
}
