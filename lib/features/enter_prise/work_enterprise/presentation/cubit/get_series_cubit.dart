import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/response/series_response_model.dart';
import '../../data/repository/get_series_repository.dart';

part 'get_series_state.dart';

class GetSeriesCubit extends Cubit<GetSeriesState> {
  final GetSeriesRepository _repository;

  GetSeriesCubit(this._repository) : super(GetSeriesInitial());

  Future<void> getSeries() async {
    emit(GetSeriesLoading());
    final result = await _repository.getSeries();
    result.fold(
      (error) => emit(GetSeriesError(error.message)),
      (response) => emit(GetSeriesLoaded(response.results)),
    );
  }

  void removeSeriesLocally(int id) {
    if (state is GetSeriesLoaded) {
      final currentList = (state as GetSeriesLoaded).series;
      final newList = currentList.where((s) => s.id != id).toList();
      emit(GetSeriesLoaded(newList));
    }
  }
}
