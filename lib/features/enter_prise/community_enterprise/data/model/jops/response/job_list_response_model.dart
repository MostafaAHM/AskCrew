import 'jop_item_model.dart';

class JobsResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<JobItemModel> results;

  JobsResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory JobsResponseModel.fromJson(Map<String, dynamic> json) {
    return JobsResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => JobItemModel.fromJson(e))
          .toList(),
    );
  }
}
