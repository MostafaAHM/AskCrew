import 'dart:io';
import 'package:dio/dio.dart';

class CreateWorkshopRequestModel {
  final String name;
  final String description;
  final File? coverImage;
  final String? coverImageUrl; // For update when image is not changed
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String specialization;
  final int numberOfParticipants;

  CreateWorkshopRequestModel({
    required this.name,
    required this.description,
    this.coverImage,
    this.coverImageUrl,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.specialization,
    required this.numberOfParticipants,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'specialization': specialization,
      'number_of_participants': numberOfParticipants,
    };

    if (coverImage != null) {
      if (await coverImage!.exists()) {
        String fileName = coverImage!.path.split('/').last;
        map['cover_image'] = await MultipartFile.fromFile(
          coverImage!.path,
          filename: fileName,
        );
      }
    }

    return FormData.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'cover_image': coverImageUrl ?? '',
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'specialization': specialization,
      'number_of_participants': numberOfParticipants,
    };
  }
}
