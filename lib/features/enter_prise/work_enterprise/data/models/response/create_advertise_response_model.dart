class CreateAdvertiseResponseModel {
  final int id;
  final String name;
  final String price;
  final String coverImage;
  final List<ActorResponseData> actors;
  final String trailer;
  final int viewsCount;
  final CategoryData category;
  final String createdAt;
  final String updatedAt;

  CreateAdvertiseResponseModel({
    required this.id,
    required this.name,
    required this.price,
    required this.coverImage,
    required this.actors,
    required this.trailer,
    required this.viewsCount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreateAdvertiseResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateAdvertiseResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      coverImage: json['cover_image'] ?? '',
      actors: (json['actors'] as List?)
              ?.map((e) => ActorResponseData.fromJson(e))
              .toList() ??
          [],
      trailer: json['trailer'] ?? '',
      viewsCount: json['views_count'] ?? 0,
      category: CategoryData.fromJson(json['category'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cover_image': coverImage,
      'actors': actors.map((e) => e.toJson()).toList(),
      'trailer': trailer,
      'views_count': viewsCount,
      'category': category.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ActorResponseData {
  final String name;
  final String image;

  ActorResponseData({
    required this.name,
    required this.image,
  });

  factory ActorResponseData.fromJson(Map<String, dynamic> json) {
    return ActorResponseData(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}

class CategoryData {
  final int id;
  final String name;
  final String image;

  CategoryData({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
