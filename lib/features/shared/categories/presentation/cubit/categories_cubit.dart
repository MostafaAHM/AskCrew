import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/category_model.dart';
import '../../data/repo/categories_repository.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  Future<void> getCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final result = await _repository.getCategories();
    result.fold(
      (error) => emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: error.message,
      )),
      (categories) => emit(state.copyWith(
        status: CategoriesStatus.success,
        categories: categories,
      )),
    );
  }
}
