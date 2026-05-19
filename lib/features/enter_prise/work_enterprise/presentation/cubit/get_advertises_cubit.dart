import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/get_advertises_repository.dart';
import 'get_advertises_state.dart';

class GetAdvertisesCubit extends Cubit<GetAdvertisesState> {
  final GetAdvertisesRepository _repository;

  GetAdvertisesCubit(this._repository) : super(const GetAdvertisesInitial());

  Future<void> getAdvertises() async {
    emit(const GetAdvertisesLoading());

    final result = await _repository.getAdvertises();

    result.fold(
      (error) => emit(GetAdvertisesError(error.message)),
      (advertises) => emit(GetAdvertisesLoaded(advertises)),
    );
  }

  void removeAdvertiseLocally(int advertiseId) {
    if (state is GetAdvertisesLoaded) {
      final currentAdvertises = (state as GetAdvertisesLoaded).advertises;
      final updatedAdvertises = currentAdvertises.where((a) => a.id != advertiseId).toList();
      emit(GetAdvertisesLoaded(updatedAdvertises));
    }
  }
}
