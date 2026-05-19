class TransactionModel {
  final int id;
  final String amount;
  final String currency;
  final String description;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? '0.00',
      currency: json['currency'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TransactionsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<TransactionModel> results;

  TransactionsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List?)
              ?.map((e) => TransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
