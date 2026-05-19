class ExperienceLevelModel {
  final String id;
  final String name;
  final String description;
  final bool isSelected;

  ExperienceLevelModel({
    required this.id,
    required this.name,
    required this.description,
    this.isSelected = false,
  });

  ExperienceLevelModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isSelected,
  }) {
    return ExperienceLevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isSelected': isSelected,
    };
  }

  factory ExperienceLevelModel.fromJson(Map<String, dynamic> json) {
    return ExperienceLevelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Predefined experience levels
  static List<ExperienceLevelModel> getDefaultExperienceLevels() {
    return [
      ExperienceLevelModel(
        id: '1',
        name: 'Beginner',
        description: 'less than 1 year',
      ),
      ExperienceLevelModel(
        id: '2',
        name: 'Intermediate',
        description: '1 - 3 years',
      ),
      ExperienceLevelModel(
        id: '3',
        name: 'Advanced',
        description: '3 - 7 years',
      ),
      ExperienceLevelModel(id: '4', name: 'Expert', description: '+7 years'),
    ];
  }
}
