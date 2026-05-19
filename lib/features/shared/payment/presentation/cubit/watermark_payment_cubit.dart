import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../data/repository/watermark_payment_repository.dart';

part 'watermark_payment_state.dart';

class WatermarkPaymentCubit extends Cubit<WatermarkPaymentState> {
  final WatermarkPaymentRepository repository;

  WatermarkPaymentCubit(this.repository) : super(WatermarkPaymentInitial());

  Future<void> startWatermarkPayment() async {
    emit(WatermarkPaymentLoading());
    final result = await repository.createWatermarkCharge();
    result.fold(
      (failure) => emit(WatermarkPaymentFailure(failure.message)),
      (charge) => emit(WatermarkPaymentChargeCreated(charge.transactionUrl)),
    );
  }

  void onCheckoutFinished() {
    emit(WatermarkPaymentVerifying());
    _pollVerificationStatus();
  }

  Future<void> _pollVerificationStatus() async {
    // Optimistic update after payment flow
    // In a real scenario, we would poll the backend until 'water_mark' becomes true

    await Future.delayed(const Duration(milliseconds: 500));

    // Optimistic local update
    final currentUser = UserHelper.userNotifier.value;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(waterMark: true);
      UserHelper.setUser(updatedUser);
    }

    emit(WatermarkPaymentVerified());
  }
}
