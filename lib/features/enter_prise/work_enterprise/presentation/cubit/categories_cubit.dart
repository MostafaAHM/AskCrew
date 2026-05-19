import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/categories_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesCubit(this._repository) : super(CategoriesInitial());

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    final result = await _repository.getCategories();
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (response) => emit(CategoriesLoaded(response.categories)),
    );
  }
}
