import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/create_season_repository.dart';
import '../../data/models/request/create_season_request_model.dart';
import 'create_season_state.dart';

class CreateSeasonCubit extends Cubit<CreateSeasonState> {
  final CreateSeasonRepository _repository;

  CreateSeasonCubit(this._repository) : super(CreateSeasonInitial());

  Future<void> createSeason(CreateSeasonRequestModel request) async {
    emit(CreateSeasonLoading());
    
    final result = await _repository.createSeason(model: request);
    
    result.fold(
      (exception) => emit(CreateSeasonError(exception.message)),
      (response) => emit(CreateSeasonSuccess(
        seasonId: response.id,
        message: response.message,
      )),
    );
  }
}
