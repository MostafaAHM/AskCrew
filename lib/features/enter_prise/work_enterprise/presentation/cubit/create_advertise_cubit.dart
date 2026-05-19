
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request/create_advertise_request_model.dart';
import '../../data/repository/create_advertise_repository.dart';
import 'create_advertise_state.dart';

class CreateAdvertiseCubit extends Cubit<CreateAdvertiseState> {
  final CreateAdvertiseRepository _repository;

  CreateAdvertiseCubit(this._repository) : super(const CreateAdvertiseInitial());

  Future<void> createAdvertise(CreateAdvertiseRequestModel model) async {
    emit(const CreateAdvertiseLoading());

    final result = await _repository.createAdvertise(model: model);

    result.fold(
      (error) => emit(CreateAdvertiseError(error.message)),
      (response) => emit(const CreateAdvertiseSuccess('Advertise created successfully!')),
    );
  }

  void reset() {
    emit(const CreateAdvertiseInitial());
  }
}
