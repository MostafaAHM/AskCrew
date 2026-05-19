class CreateSeriesResponseModel {
  final int id;
  final String title;
  final String about;
  final String coverPhoto;
  final int categoryId;
  final String message;

  CreateSeriesResponseModel({
    required this.id,
    required this.title,
    required this.about,
    required this.coverPhoto,
    required this.categoryId,
    required this.message,
  });

  factory CreateSeriesResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateSeriesResponseModel(
      id: json['id'] ?? json['data']?['id'] ?? 0,
      title: json['title'] ?? json['data']?['title'] ?? '',
      about: json['about'] ?? json['data']?['about'] ?? '',
      coverPhoto: json['cover_photo'] ?? json['data']?['cover_photo'] ?? '',
      categoryId: json['category_id'] ?? json['data']?['category_id'] ?? 0,
      message: json['message'] ?? 'Series created successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'about': about,
      'cover_photo': coverPhoto,
      'category_id': categoryId,
      'message': message,
    };
  }
}
