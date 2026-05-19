class TalentWorkModel {
  final int id;
  final String title;
  final String posterUrl;
  final String category;

  const TalentWorkModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.category,
  });

  factory TalentWorkModel.fromJson(Map<String, dynamic> json) {
    return TalentWorkModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterUrl: json['poster'] ?? '',
      category: json['role_in_work'] ?? '',
    );
  }
}
