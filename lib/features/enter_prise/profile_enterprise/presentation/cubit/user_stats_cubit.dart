import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/profile_repository.dart';
import 'user_stats_state.dart';

class UserStatsCubit extends Cubit<UserStatsState> {
  final ProfileRepository _repository;

  UserStatsCubit(this._repository) : super(UserStatsInitial());

  Future<void> getMyStats() async {
    emit(UserStatsLoading());

    final result = await _repository.getMyStats();

    result.fold(
      (error) => emit(UserStatsError(error.toString())),
      (stats) => emit(UserStatsLoaded(stats)),
    );
  }
}
