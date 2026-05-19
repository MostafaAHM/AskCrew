
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/update_series_repository.dart';
import '../../data/models/request/update_series_request_model.dart';
import 'update_series_state.dart';

class UpdateSeriesCubit extends Cubit<UpdateSeriesState> {
  final UpdateSeriesRepository _repository;

  UpdateSeriesCubit(this._repository) : super(UpdateSeriesInitial());

  Future<void> updateSeries(UpdateSeriesRequestModel request) async {
    emit(UpdateSeriesLoading());
    
    final result = await _repository.updateSeries(model: request);
    
    result.fold(
      (exception) => emit(UpdateSeriesError(exception.message)),
      (response) => emit(UpdateSeriesSuccess(
        seriesId: response.id,
        message: response.message,
      )),
    );
  }
}
