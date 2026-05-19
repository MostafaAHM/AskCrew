import 'dart:io';
import 'package:dio/dio.dart';

class CreateSeriesRequestModel {
  final String title;
  final String about;
  final File coverPhoto;
  final int categoryId;

  CreateSeriesRequestModel({
    required this.title,
    required this.about,
    required this.coverPhoto,
    required this.categoryId,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'title': title,
      'about': about,
      'cover_photo': await MultipartFile.fromFile(
        coverPhoto.path,
        filename: coverPhoto.path.split('/').last,
      ),
      'category_id': categoryId,
    });
  }
}
