import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repository/explore_repository.dart';
import '../../data/models/explore_response_model.dart';

part 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final ExploreRepository _repository;

  ExploreCubit(this._repository) : super(ExploreInitial());

  Future<void> getExploreContent() async {
    emit(ExploreLoading());
    
    final result = await _repository.getExploreContent();
    
    result.fold(
      (error) => emit(ExploreError(error.message)),
      (response) => emit(ExploreLoaded(response.items)),
    );
  }
}

