import '../../../data/models/transaction_model.dart';
import '../../../../../shared/withdraw/data/model/collect_request_model.dart';

// ── Unified item for both payment transactions and withdraw requests ──────────
class AllTransactionItem {
  final int id;
  final String amount;
  final String createdAt;
  final bool isWithdraw;   // false = deposit/payment, true = collect request
  final String? status;    // only for withdraw: pending / approved / rejected
  final String? source;    // only for withdraw: wallet / points
  final String? description; // only for payments
  final String? currency;    // only for payments

  const AllTransactionItem({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.isWithdraw,
    this.status,
    this.source,
    this.description,
    this.currency,
  });

  /// Build from a payment transaction
  factory AllTransactionItem.fromPayment(TransactionModel t) =>
      AllTransactionItem(
        id: t.id,
        amount: t.amount,
        createdAt: t.createdAt,
        isWithdraw: false,
        description: t.description,
        currency: t.currency,
      );

  /// Build from a collect request (withdraw)
  factory AllTransactionItem.fromCollect(CollectRequestModel c) =>
      AllTransactionItem(
        id: c.id,
        amount: c.amount,
        createdAt: c.createdAt,
        isWithdraw: true,
        status: c.status,
        source: c.source,
      );

  DateTime get dateTime {
    try {
      return DateTime.parse(createdAt);
    } catch (_) {
      return DateTime(0);
    }
  }
}
// ─────────────────────────────────────────────────────────────────────────────

abstract class RecentTransactionsState {}

class RecentTransactionsInitial extends RecentTransactionsState {}

class RecentTransactionsLoading extends RecentTransactionsState {}

class RecentTransactionsLoaded extends RecentTransactionsState {
  final List<AllTransactionItem> items;
  RecentTransactionsLoaded(this.items);
}

class RecentTransactionsError extends RecentTransactionsState {
  final String message;
  RecentTransactionsError(this.message);
}
