
import 'dart:io';
import 'package:dio/dio.dart';

class CreateAdvertiseRequestModel {
  final String name;
  final String about;
  final double price;
  final File coverImage;
  final List<ActorRequestData> actors;
  final String trailerId;
  final int categoryId;
  final bool isReady;
  final String videoId;

  CreateAdvertiseRequestModel({
    required this.name,
    required this.about,
    required this.price,
    required this.coverImage,
    required this.actors,
    required this.trailerId,
    required this.categoryId,
    required this.isReady,
    required this.videoId,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name,
      'about': about,
      'price': price,
      'trailer': trailerId,
      'category_id': categoryId,
      'is_ready': isReady ? 1 : 0,
      'video': videoId,
    };

    String fileName = coverImage.path.split('/').last;
    map['cover_image'] = await MultipartFile.fromFile(
      coverImage.path,
      filename: fileName,
    );

    for (int i = 0; i < actors.length; i++) {
      map['actors_data[$i][name]'] = actors[i].name;
      
      if (actors[i].image != null) {
        String fileName = actors[i].image!.path.split('/').last;
        map['actors_data[$i][image]'] = await MultipartFile.fromFile(
          actors[i].image!.path,
          filename: fileName,
        );
      }
    }
    
    return FormData.fromMap(map);
  }
}

class ActorRequestData {
  final String name;
  final File? image;

  ActorRequestData({
    required this.name,
    this.image,
  });
}
