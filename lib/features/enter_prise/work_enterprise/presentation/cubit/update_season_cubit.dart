
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/update_season_repository.dart';
import '../../data/models/request/update_season_request_model.dart';
import 'update_season_state.dart';

class UpdateSeasonCubit extends Cubit<UpdateSeasonState> {
  final UpdateSeasonRepository _repository;

  UpdateSeasonCubit(this._repository) : super(UpdateSeasonInitial());

  Future<void> updateSeason(UpdateSeasonRequestModel request) async {
    emit(UpdateSeasonLoading());
    
    final result = await _repository.updateSeason(model: request);
    
    result.fold(
      (exception) => emit(UpdateSeasonError(exception.message)),
      (response) => emit(UpdateSeasonSuccess(
        seasonId: response.id,
        message: response.message,
      )),
    );
  }
}
