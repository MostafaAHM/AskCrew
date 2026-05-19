import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final DateTime releaseDate;
  final double rating;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.releaseDate,
    required this.rating,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    posterUrl: json['posterUrl'] ?? json['poster_url'] ?? '',
    releaseDate: json['releaseDate'] != null
        ? DateTime.tryParse(json['releaseDate']) ?? DateTime.now()
        : json['release_date'] != null
        ? DateTime.tryParse(json['release_date']) ?? DateTime.now()
        : DateTime.now(),
    rating: (json['rating'] ?? json['rate'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'posterUrl': posterUrl,
    'releaseDate': releaseDate.toIso8601String(),
    'rating': rating,
  };

  @override
  List<Object?> get props => [id, title, posterUrl, releaseDate, rating];
}
