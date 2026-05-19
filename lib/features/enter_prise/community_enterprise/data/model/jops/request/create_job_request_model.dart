import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class CreateJobRequestModel {
  final String companyName;
  final String jobTitle;
  final String about;
  final bool isActive;
  final File? image;

  const CreateJobRequestModel({
    required this.companyName,
    required this.jobTitle,
    required this.about,
    this.isActive = true,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'job_title': jobTitle,
      'about': about,
      'is_active': isActive,
    };
  }

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'company_name': companyName,
      'job_title': jobTitle,
      'about': about,
      'is_active': isActive,
    };

    if (image != null) {
      map['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: p.basename(image!.path),
      );
    }

    return FormData.fromMap(map);
  }
}
