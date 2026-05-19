import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/change_password_repository.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordRepository _repository;

  ChangePasswordCubit(this._repository) : super(const ChangePasswordInitial());

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordLoading());

    final result = await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    result.fold(
      (error) => emit(ChangePasswordError(error.message)),
      (_) => emit(const ChangePasswordSuccess()),
    );
  }
}

