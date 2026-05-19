import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../../core/models/base_response_model.dart';
import '../../../data/model/student_request_model.dart';
import '../../../data/repository/student_repository.dart';

part 'register_student_state.dart';

class RegisterStudentCubit extends Cubit<RegisterStudentState> {
  final StudentRepository repository;

  RegisterStudentCubit(this.repository) : super(RegisterStudentInitial());

  Future<void> registerStudent(StudentRequestModel model) async {
    emit(RegisterStudentLoading());

    final result = await repository.registerStudent(model: model);

    result.fold(
      (error) {
        emit(RegisterStudentError(error.message));
      },
      (response) {
        emit(RegisterStudentSuccess(response));
      },
    );
  }
}
