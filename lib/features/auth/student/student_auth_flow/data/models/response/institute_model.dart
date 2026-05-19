class InstituteModel {
  final String id;
  final String name;
  final bool isSelected;

  InstituteModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  InstituteModel copyWith({String? id, String? name, bool? isSelected}) {
    return InstituteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isSelected': isSelected};
  }

  factory InstituteModel.fromJson(Map<String, dynamic> json) {
    return InstituteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }

  // Predefined institutes based on the image
  static List<InstituteModel> getDefaultInstitutes() {
    return [
      InstituteModel(id: '1', name: 'Institute of Cinema'),
      InstituteModel(id: '2', name: 'Institute of Music'),
      InstituteModel(id: '3', name: 'Arts Academy'),
      InstituteModel(id: '4', name: 'Conservatoire Institute'),
      InstituteModel(id: '5', name: 'Institute of Theatre'),
      InstituteModel(id: '6', name: 'Faculty of Fine Arts'),
      InstituteModel(id: '7', name: 'Other'),
    ];
  }
}
