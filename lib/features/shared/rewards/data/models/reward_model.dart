class RewardsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<RewardModel> results;

  RewardsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory RewardsResponse.fromJson(Map<String, dynamic> json) {
    return RewardsResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => RewardModel.fromJson(e))
          .toList(),
    );
  }
}

class RewardModel {
  final int id;
  final String name;
  final String description;
  final int points;
  final String? image;
  final bool isActive;
  final DateTime createdAt;

  // Additional fields for UI
  final String? discountTag;
  final bool canClaim;

  const RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    this.image,
    required this.isActive,
    required this.createdAt,
    this.discountTag,
    this.canClaim = true,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      image: json['image'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      // These fields are not in the API but kept for UI compatibility
      discountTag: null,
      canClaim: true,
    );
  }

  // Getter for backward compatibility with existing UI code
  String get title => name;
  String? get imageUrl => image;
}
