import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/delete_account_repository.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DeleteAccountRepository _repository;

  DeleteAccountCubit(this._repository) : super(const DeleteAccountInitial());

  Future<void> deleteAccount() async {
    emit(const DeleteAccountLoading());

    final result = await _repository.deleteAccount();

    result.fold(
      (error) => emit(DeleteAccountError(error.message)),
      (_) => emit(const DeleteAccountSuccess()),
    );
  }
}

