import 'dart:io';
import 'package:dio/dio.dart';

class CreateBookingItemRequestModel {
  final String name;
  final String quantity; // Changed from int to String to accept any text
  final double pricePerDay;
  final String location;
  final String type;
  final String? description; // Added description field
  final File? image;
  final String? imageUrl; // For update when image is not changed
  final bool? isActive;
  final DateTime? startTime;
  final DateTime? endTime;

  CreateBookingItemRequestModel({
    required this.name,
    required this.quantity,
    required this.pricePerDay,
    required this.location,
    required this.type,
    this.description,
    this.image,
    this.imageUrl,
    this.isActive,
    this.startTime,
    this.endTime,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'price_per_day': pricePerDay,
      'location': location,
      'type': type,
      'is_active': isActive ?? true,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (startTime != null) 'start_time': startTime!.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
    };

    if (image != null) {
      String fileName = image!.path.split('/').last;
      map['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: fileName,
      );
    }

    return FormData.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price_per_day': pricePerDay,
      'location': location,
      'type': type,
      'image': imageUrl ?? '',
      'is_active': isActive ?? true,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (startTime != null) 'start_time': startTime!.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
    };
  }
}
