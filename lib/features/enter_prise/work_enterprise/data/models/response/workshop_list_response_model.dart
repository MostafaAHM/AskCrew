import 'workshop_response_model.dart';

class WorkshopListResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<WorkshopResponseModel> results;

  WorkshopListResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory WorkshopListResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkshopListResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => WorkshopResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

