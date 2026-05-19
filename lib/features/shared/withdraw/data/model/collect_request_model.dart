/// Model for a single collect/withdraw request
class CollectRequestModel {
  final int id;
  final int user;
  final String amount;
  final String source; // 'wallet' | 'points'
  final String status; // 'pending' | 'approved' | 'rejected'
  final String createdAt;
  final String updatedAt;

  const CollectRequestModel({
    required this.id,
    required this.user,
    required this.amount,
    required this.source,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollectRequestModel.fromJson(Map<String, dynamic> json) {
    return CollectRequestModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      source: json['source']?.toString() ?? 'wallet',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

/// Paginated response wrapper
class CollectRequestsResponse {
  final int count;
  final List<CollectRequestModel> results;

  const CollectRequestsResponse({required this.count, required this.results});

  factory CollectRequestsResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['results'];
    final results = rawList is List
        ? rawList
            .map((item) => CollectRequestModel.fromJson(
                  item is Map ? Map<String, dynamic>.from(item) : {},
                ))
            .toList()
        : <CollectRequestModel>[];
    return CollectRequestsResponse(
      count: json['count'] ?? 0,
      results: results,
    );
  }
}
