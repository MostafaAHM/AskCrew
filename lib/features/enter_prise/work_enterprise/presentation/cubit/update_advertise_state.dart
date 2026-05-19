
import 'package:equatable/equatable.dart';

abstract class UpdateAdvertiseState extends Equatable {
  const UpdateAdvertiseState();

  @override
  List<Object> get props => [];
}

class UpdateAdvertiseInitial extends UpdateAdvertiseState {
  const UpdateAdvertiseInitial();
}

class UpdateAdvertiseLoading extends UpdateAdvertiseState {
  const UpdateAdvertiseLoading();
}

class UpdateAdvertiseSuccess extends UpdateAdvertiseState {
  final String message;
  const UpdateAdvertiseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateAdvertiseError extends UpdateAdvertiseState {
  final String message;
  const UpdateAdvertiseError(this.message);

  @override
  List<Object> get props => [message];
}
