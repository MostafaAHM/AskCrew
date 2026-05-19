import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/models/base_response_model.dart';
import '../../data/repository/swap_account_repository.dart';

part 'swap_account_state.dart';

class SwapAccountCubit extends Cubit<SwapAccountState> {
  final SwapAccountRepository _repository;

  SwapAccountCubit(this._repository) : super(SwapAccountInitial());

  Future<void> swapToEnterprise() async {
    emit(SwapAccountLoading());
    final result = await _repository.swapToEnterprise();
    result.fold(
      (exception) =>
          emit(SwapAccountError(exception.message, code: exception.code)),
      (response) => emit(SwapAccountSuccess(response)),
    );
  }

  Future<void> swapToStudent() async {
    emit(SwapAccountLoading());
    final result = await _repository.swapToStudent();
    result.fold(
      (exception) =>
          emit(SwapAccountError(exception.message, code: exception.code)),
      (response) => emit(SwapAccountSuccess(response)),
    );
  }

  Future<void> swapToViewer() async {
    emit(SwapAccountLoading());
    final result = await _repository.swapToViewer();
    result.fold(
      (exception) =>
          emit(SwapAccountError(exception.message, code: exception.code)),
      (response) => emit(SwapAccountSuccess(response)),
    );
  }
}
