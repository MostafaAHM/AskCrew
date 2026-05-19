import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/delete_advertise_repository.dart';
import 'delete_advertise_state.dart';

class DeleteAdvertiseCubit extends Cubit<DeleteAdvertiseState> {
  final DeleteAdvertiseRepository _repository;

  DeleteAdvertiseCubit(this._repository) : super(const DeleteAdvertiseInitial());

  Future<void> deleteAdvertise(int advertiseId) async {
    emit(const DeleteAdvertiseLoading());

    final result = await _repository.deleteAdvertise(advertiseId: advertiseId);

    result.fold(
      (error) => emit(DeleteAdvertiseError(error.message)),
      (_) => emit(const DeleteAdvertiseSuccess('Advertise deleted successfully!')),
    );
  }

  void reset() {
    emit(const DeleteAdvertiseInitial());
  }
}
