import 'package:easy_localization/easy_localization.dart';

class RewardHistoryResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<RewardHistoryModel> results;

  RewardHistoryResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory RewardHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RewardHistoryResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => RewardHistoryModel.fromJson(e))
          .toList(),
    );
  }
}

class RewardHistoryModel {
  final int points;
  final String title;
  final String? content;
  final String? code;
  final String? image;
  final DateTime createdAt;

  RewardHistoryModel({
    required this.points,
    required this.title,
    this.content,
    this.code,
    this.image,
    required this.createdAt,
  });

  factory RewardHistoryModel.fromJson(Map<String, dynamic> json) {
    final rewardData = json['reward'] as Map<String, dynamic>?;

    return RewardHistoryModel(
      points: rewardData != null
          ? (rewardData['points'] ?? 0)
          : (json['points'] ?? 0),
      title: rewardData != null
          ? (rewardData['name'] ?? '')
          : (json['title'] ?? ''),
      content: rewardData != null ? rewardData['content'] : json['content'],
      code: json['code'],
      image: rewardData != null ? rewardData['image'] : json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }
}
