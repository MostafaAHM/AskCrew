
import 'dart:io';
import 'package:dio/dio.dart';

class UpdateSeriesRequestModel {
  final int seriesId;
  final String? title;
  final String? about;
  final File? coverPhoto;
  final int? categoryId;

  UpdateSeriesRequestModel({
    required this.seriesId,
    this.title,
    this.about,
    this.coverPhoto,
    this.categoryId,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      '_method': 'PATCH',
    };

    if (title != null) map['title'] = title;
    if (about != null) map['about'] = about;
    if (categoryId != null) map['category_id'] = categoryId;

    if (coverPhoto != null) {
      map['cover_photo'] = await MultipartFile.fromFile(
        coverPhoto!.path,
        filename: coverPhoto!.path.split('/').last,
      );
    }

    return FormData.fromMap(map);
  }
}
