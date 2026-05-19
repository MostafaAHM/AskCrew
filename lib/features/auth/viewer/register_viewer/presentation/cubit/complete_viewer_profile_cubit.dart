import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/models/base_response_model.dart';
import '../../data/model/complete_viewer_profile_request_model.dart';
import '../../data/repo/register_repository.dart';

part 'complete_viewer_profile_state.dart';

class CompleteViewerProfileCubit extends Cubit<CompleteViewerProfileState> {
  final RegisterRepository _repository;

  CompleteViewerProfileCubit(this._repository)
    : super(CompleteViewerProfileInitial());

  Future<void> completeProfile({
    required String name,
    List<int>? favoriteCategories,
  }) async {
    emit(CompleteViewerProfileLoading());

    final model = CompleteViewerProfileRequestModel(
      name: name,
      favoriteCategories: favoriteCategories,
    );

    final result = await _repository.completeViewerProfile(model: model);

    result.fold(
      (failure) => emit(CompleteViewerProfileError(failure.message)),
      (response) => emit(CompleteViewerProfileSuccess(response)),
    );
  }
}
