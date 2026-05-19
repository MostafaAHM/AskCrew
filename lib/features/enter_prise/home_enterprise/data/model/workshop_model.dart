class WorkshopModel {
  final String id;
  final String title;
  final String instructor;
  final DateTime date;
  final String imageUrl;
  final String? description;

  const WorkshopModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.date,
    required this.imageUrl,
    this.description,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
