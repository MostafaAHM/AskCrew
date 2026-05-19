import 'package:equatable/equatable.dart';
import 'user_model.dart';

class PaginatedProfilesResponseModel extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<UserModel> results;

  const PaginatedProfilesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedProfilesResponseModel.fromJson(Map<String, dynamic> json) {
    return PaginatedProfilesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((user) => user.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}
