part of 'register_student_cubit.dart';

sealed class RegisterStudentState extends Equatable {
  const RegisterStudentState();

  @override
  List<Object?> get props => [];
}

final class RegisterStudentInitial extends RegisterStudentState {}

final class RegisterStudentLoading extends RegisterStudentState {}

final class RegisterStudentSuccess extends RegisterStudentState {
  final BaseResponseModel response;

  const RegisterStudentSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

final class RegisterStudentError extends RegisterStudentState {
  final String message;

  const RegisterStudentError(this.message);

  @override
  List<Object?> get props => [message];
}
