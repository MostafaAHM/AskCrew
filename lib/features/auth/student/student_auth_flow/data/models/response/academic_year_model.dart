class AcademicYearModel {
  final String id;
  final String name;
  final bool isSelected;

  AcademicYearModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  AcademicYearModel copyWith({String? id, String? name, bool? isSelected}) {
    return AcademicYearModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isSelected': isSelected};
  }

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Predefined academic years based on the image
  static List<AcademicYearModel> getDefaultAcademicYears() {
    return [
      AcademicYearModel(id: '1', name: 'firstYear'),
      AcademicYearModel(id: '2', name: 'secondYear'),
      AcademicYearModel(id: '3', name: 'thirdYear'),
      AcademicYearModel(id: '4', name: 'fourthYear'),
      AcademicYearModel(id: '5', name: 'graduated'),
    ];
  }
}
