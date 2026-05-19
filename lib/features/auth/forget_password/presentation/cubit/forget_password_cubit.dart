import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/forget_password_request_model.dart';
import '../../data/repository/forget_password_repository.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepository repository;

  ForgetPasswordCubit(this.repository) : super(ForgetPasswordInitial());

  Future<void> sendForgetPasswordOtp(ForgetPasswordRequestModel request) async {
    emit(ForgetPasswordLoading());

    final result = await repository.sendForgetPasswordOtp(model: request);
    result.fold(
      (failure) {
        emit(ForgetPasswordFailure(failure.message));
      },
      (response) {
        emit(ForgetPasswordSuccess());
      },
    );
  }
}
