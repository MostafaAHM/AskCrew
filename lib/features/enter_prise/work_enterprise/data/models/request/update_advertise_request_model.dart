
import 'dart:io';
import 'package:dio/dio.dart';

class UpdateAdvertiseRequestModel {
  final int advertiseId;
  final String? name;
  final double? price;
  final File? coverImage;
  final List<ActorUpdateData>? actors;
  final String? trailerId;
  final int? categoryId;
  final bool? isReady;
  final String? videoId;

  UpdateAdvertiseRequestModel({
    required this.advertiseId,
    this.name,
    this.price,
    this.coverImage,
    this.actors,
    this.trailerId,
    this.categoryId,
    this.isReady,
    this.videoId,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      '_method': 'PATCH',
    };

    if (name != null) map['name'] = name;
    if (price != null) map['price'] = price;
    if (categoryId != null) map['category_id'] = categoryId;
    if (isReady != null) map['is_ready'] = isReady! ? 1 : 0;
    
    if (videoId != null && videoId!.isNotEmpty) map['video'] = videoId;
    if (trailerId != null && trailerId!.isNotEmpty) map['trailer'] = trailerId;

    if (coverImage != null) {
      String fileName = coverImage!.path.split('/').last;
      map['cover_image'] = await MultipartFile.fromFile(
        coverImage!.path,
        filename: fileName,
      );
    }

    if (actors != null && actors!.isNotEmpty) {
      for (int i = 0; i < actors!.length; i++) {
        map['actors_data[$i][name]'] = actors![i].name;
        
        if (actors![i].imageFile != null) {
          String fileName = actors![i].imageFile!.path.split('/').last;
          map['actors_data[$i][image]'] = await MultipartFile.fromFile(
            actors![i].imageFile!.path,
            filename: fileName,
          );
        } else if (actors![i].imageUrl != null) {
          map['actors_data[$i][image]'] = actors![i].imageUrl;
        }
      }
    }
    
    return FormData.fromMap(map);
  }
}

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
