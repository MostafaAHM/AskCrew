import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/model/banner_model.dart';
import '../../data/repository/banner_repository.dart';

part 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerRepository repository;

  BannerCubit(this.repository) : super(BannerInitial());

  Future<void> getBanners() async {
    emit(BannerLoading());
    final result = await repository.getBanners();
    result.fold(
      (failure) => emit(BannerFailure(failure.message)),
      (response) => emit(BannerSuccess(response)),
    );
  }
}

