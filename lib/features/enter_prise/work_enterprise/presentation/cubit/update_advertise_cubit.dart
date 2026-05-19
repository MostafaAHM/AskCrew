
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request/update_advertise_request_model.dart';
import '../../data/repository/update_advertise_repository.dart';
import 'update_advertise_state.dart';

class UpdateAdvertiseCubit extends Cubit<UpdateAdvertiseState> {
  final UpdateAdvertiseRepository _repository;

  UpdateAdvertiseCubit(this._repository) : super(const UpdateAdvertiseInitial());

  Future<void> updateAdvertise(UpdateAdvertiseRequestModel model) async {
    emit(const UpdateAdvertiseLoading());

    final result = await _repository.updateAdvertise(model: model);

    result.fold(
      (error) => emit(UpdateAdvertiseError(error.message)),
      (response) => emit(const UpdateAdvertiseSuccess('Advertise updated successfully!')),
    );
  }

  void reset() {
    emit(const UpdateAdvertiseInitial());
  }
}
