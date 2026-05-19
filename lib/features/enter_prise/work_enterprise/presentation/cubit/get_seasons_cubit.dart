import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/response/seasons_response_model.dart';
import '../../data/repository/get_seasons_repository.dart';

part 'get_seasons_state.dart';

class GetSeasonsCubit extends Cubit<GetSeasonsState> {
  final GetSeasonsRepository _repository;

  GetSeasonsCubit(this._repository) : super(GetSeasonsInitial());

  Future<void> getSeasons(int seriesId) async {
    emit(GetSeasonsLoading());
    final result = await _repository.getSeasons(seriesId);
    result.fold(
      (error) => emit(GetSeasonsError(error.message)),
      (response) => emit(GetSeasonsLoaded(response.results)),
    );
  }
}
