import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/profile_repository.dart';
import '../../../../../shared/withdraw/data/repository/withdraw_repository.dart';
import 'recent_transactions_state.dart';

class RecentTransactionsCubit extends Cubit<RecentTransactionsState> {
  final ProfileRepository _profileRepo;
  final WithdrawRepository _withdrawRepo;

  RecentTransactionsCubit(this._profileRepo, this._withdrawRepo)
      : super(RecentTransactionsInitial());

  Future<void> getRecentTransactions() async {
    emit(RecentTransactionsLoading());

    // Fetch both in parallel
    final paymentsFuture = _profileRepo.getMyPayments(pageSize: 100);
    final collectFuture = _withdrawRepo.getCollectRequests();

    final results = await Future.wait([paymentsFuture, collectFuture]);

    final paymentsResult = results[0];
    final collectResult = results[1];

    // Collect payments
    final paymentItems = paymentsResult.fold(
      (_) => <AllTransactionItem>[],
      (resp) {
        final r = resp as dynamic; // TransactionsResponse
        return (r.results as List)
            .map((t) => AllTransactionItem.fromPayment(t))
            .toList();
      },
    );

    // Collect withdrawals
    final collectItems = collectResult.fold(
      (_) => <AllTransactionItem>[],
      (resp) {
        final r = resp as dynamic; // CollectRequestsResponse
        return (r.results as List)
            .map((c) => AllTransactionItem.fromCollect(c))
            .toList();
      },
    );

    // Merge and sort by date descending (newest first)
    final all = [...paymentItems, ...collectItems]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    emit(RecentTransactionsLoaded(all));
  }
}
