class CompleteViewerProfileRequestModel {
  final String name;
  final List<int>? favoriteCategories;

  CompleteViewerProfileRequestModel({
    required this.name,
    this.favoriteCategories,
  });

  Map<String, dynamic> toFormData() {
    final map = <String, dynamic>{'Name': name};

    if (favoriteCategories != null && favoriteCategories!.isNotEmpty) {
      map['favorite_categories'] = favoriteCategories;
    }

    return map;
  }
}
