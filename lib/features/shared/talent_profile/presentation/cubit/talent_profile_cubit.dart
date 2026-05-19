import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/talent_profile_repo.dart';
import 'talent_profile_state.dart';

class TalentProfileCubit extends Cubit<TalentProfileState> {
  final TalentProfileRepository _repository;

  TalentProfileCubit(this._repository) : super(TalentProfileInitial());

  Future<void> getTalentProfile(String id) async {
    emit(TalentProfileLoading());
    final result = await _repository.getTalentProfile(id);
    result.fold(
      (error) => emit(TalentProfileError(error.message)),
      (profile) => emit(TalentProfileLoaded(profile)),
    );
  }
}
