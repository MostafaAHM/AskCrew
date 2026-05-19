import 'dart:io';
import 'package:dio/dio.dart';

class ActorRequestData {
  final String name;
  final File image;

  ActorRequestData({
    required this.name,
    required this.image,
  });
}

class CreateSeasonRequestModel {
  final int seriesId;
  final List<ActorRequestData> actorsData;
  final double price;
  final File coverPhoto;
  final String trailer;
  final String seasonNumber;

  CreateSeasonRequestModel({
    required this.seriesId,
    required this.actorsData,
    required this.price,
    required this.coverPhoto,
    required this.trailer,
    required this.seasonNumber,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> formDataMap = {
      'series_id': seriesId,
      'price': price,
      'trailer': trailer,
      'season_number': seasonNumber,
    };

    if (coverPhoto.existsSync()) {
      formDataMap['cover_photo'] = await MultipartFile.fromFile(
        coverPhoto.path,
        filename: coverPhoto.path.split('/').last,
      );
    }

    for (int i = 0; i < actorsData.length; i++) {
      formDataMap['actors_data[$i][name]'] = actorsData[i].name;
      
      if (actorsData[i].image.existsSync()) {
        formDataMap['actors_data[$i][image]'] = await MultipartFile.fromFile(
          actorsData[i].image.path,
          filename: actorsData[i].image.path.split('/').last,
        );
      }
    }

    return FormData.fromMap(formDataMap);
  }
}
