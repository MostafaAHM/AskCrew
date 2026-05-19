import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/request/enterprise_requst_model.dart';
import '../../../../data/repository/enterprise_repository.dart';

part 'register_enterprise_state.dart';

class RegisterEnterpriseCubit extends Cubit<RegisterEnterpriseState> {
  final EnterpriseRepository repository;

  RegisterEnterpriseCubit(this.repository) : super(RegisterEnterpriseInitial());

  Future<void> registerEnterprise({
    required EnterpriseRequestModel model,
  }) async {
    emit(RegisterEnterpriseLoading());

    try {
      await repository.registerEnterprise(model: model);
      emit(RegisterEnterpriseSuccess());
    } catch (e) {
      emit(RegisterEnterpriseError(e.toString()));
    }
  }
}
