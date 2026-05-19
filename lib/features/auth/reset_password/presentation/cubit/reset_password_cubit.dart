import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/reset_password_request_model.dart';
import '../../data/repository/reset_password_repository.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepository repository;

  ResetPasswordCubit(this.repository) : super(ResetPasswordInitial());

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    emit(ResetPasswordLoading());

    final result = await repository.resetPassword(model: request);
    result.fold(
      (failure) {
        emit(ResetPasswordFailure(failure.message));
      },
      (response) {
        emit(ResetPasswordSuccess());
      },
    );
  }
}
