import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repository/logout_repository.dart';

import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutRepository repository;

  LogoutCubit(this.repository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    final result = await repository.logout();
    result.fold(
      (failure) {
        emit(LogoutFailure(failure.message));
      },
      (response) {
        getIt<NotificationsCubit>().clearOnLogout();
        emit(LogoutSuccess());
      },
    );
  }
}
