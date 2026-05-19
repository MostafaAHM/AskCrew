class SpecificationModel {
  final String id;
  final String name;
  final bool isSelected;

  SpecificationModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  SpecificationModel copyWith({String? id, String? name, bool? isSelected}) {
    return SpecificationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isSelected': isSelected};
  }

  factory SpecificationModel.fromJson(Map<String, dynamic> json) {
    return SpecificationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }
}

class SpecificationCategoryModel {
  final String categoryName;
  final List<SpecificationModel> items;
  final bool isExpanded;

  SpecificationCategoryModel({
    required this.categoryName,
    required this.items,
    this.isExpanded = false,
  });

  SpecificationCategoryModel copyWith({
    String? categoryName,
    List<SpecificationModel>? items,
    bool? isExpanded,
  }) {
    return SpecificationCategoryModel(
      categoryName: categoryName ?? this.categoryName,
      items: items ?? this.items,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'items': items.map((i) => i.toJson()).toList(),
      'isExpanded': isExpanded,
    };
  }

  factory SpecificationCategoryModel.fromJson(Map<String, dynamic> json) {
    return SpecificationCategoryModel(
      categoryName: json['categoryName'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((i) => SpecificationModel.fromJson(i))
              .toList() ??
          [],
      isExpanded: json['isExpanded'] ?? false,
    );
  }
}
