part of 'register_enterprise_cubit.dart';

sealed class RegisterEnterpriseState extends Equatable {
  const RegisterEnterpriseState();

  @override
  List<Object?> get props => [];
}

final class RegisterEnterpriseInitial extends RegisterEnterpriseState {}

final class RegisterEnterpriseLoading extends RegisterEnterpriseState {}

final class RegisterEnterpriseSuccess extends RegisterEnterpriseState {}

final class RegisterEnterpriseError extends RegisterEnterpriseState {
  final String message;

  const RegisterEnterpriseError(this.message);

  @override
  List<Object?> get props => [message];
}
