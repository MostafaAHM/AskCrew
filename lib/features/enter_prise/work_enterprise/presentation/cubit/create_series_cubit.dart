import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/create_series_repository.dart';
import '../../data/models/request/create_series_request_model.dart';
import 'create_series_state.dart';

class CreateSeriesCubit extends Cubit<CreateSeriesState> {
  final CreateSeriesRepository _repository;

  CreateSeriesCubit(this._repository) : super(CreateSeriesInitial());

  Future<void> createSeries(CreateSeriesRequestModel request) async {
    emit(CreateSeriesLoading());
    
    final result = await _repository.createSeries(model: request);
    
    result.fold(
      (exception) => emit(CreateSeriesError(exception.message)),
      (response) => emit(CreateSeriesSuccess(
        seriesId: response.id,
        message: response.message,
      )),
    );
  }
}
