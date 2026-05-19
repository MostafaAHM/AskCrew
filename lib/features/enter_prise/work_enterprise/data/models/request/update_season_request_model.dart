
import 'dart:io';
import 'package:dio/dio.dart';

class ActorUpdateData {
  final String name;
  final File? imageFile;
  final String? imageUrl;

  ActorUpdateData({
    required this.name,
    this.imageFile,
    this.imageUrl,
  });
}

class UpdateSeasonRequestModel {
  final int seasonId;
  final int? seriesId;
  final List<ActorUpdateData>? actorsData;
  final double? price;
  final File? coverPhoto;
  final String? trailer;
  final String? seasonNumber;

  UpdateSeasonRequestModel({
    required this.seasonId,
    this.seriesId,
    this.actorsData,
    this.price,
    this.coverPhoto,
    this.trailer,
    this.seasonNumber,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      '_method': 'PATCH',
    };

    if (seriesId != null) map['series_id'] = seriesId;
    if (price != null) map['price'] = price;
    if (trailer != null) map['trailer'] = trailer;
    if (seasonNumber != null) map['season_number'] = seasonNumber;

    if (coverPhoto != null && coverPhoto!.existsSync()) {
      map['cover_photo'] = await MultipartFile.fromFile(
        coverPhoto!.path,
        filename: coverPhoto!.path.split('/').last,
      );
    }

    if (actorsData != null && actorsData!.isNotEmpty) {
      for (int i = 0; i < actorsData!.length; i++) {
        map['actors_data[$i][name]'] = actorsData![i].name;
        
        if (actorsData![i].imageFile != null && actorsData![i].imageFile!.existsSync()) {
          map['actors_data[$i][image]'] = await MultipartFile.fromFile(
            actorsData![i].imageFile!.path,
            filename: actorsData![i].imageFile!.path.split('/').last,
          );
        } else if (actorsData![i].imageUrl != null) {
          map['actors_data[$i][image]'] = actorsData![i].imageUrl;
        }
      }
    }

    return FormData.fromMap(map);
  }
}
