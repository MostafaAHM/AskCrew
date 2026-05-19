
import 'package:equatable/equatable.dart';

abstract class CreateAdvertiseState extends Equatable {
  const CreateAdvertiseState();

  @override
  List<Object> get props => [];
}

class CreateAdvertiseInitial extends CreateAdvertiseState {
  const CreateAdvertiseInitial();
}

class CreateAdvertiseLoading extends CreateAdvertiseState {
  const CreateAdvertiseLoading();
}

class CreateAdvertiseSuccess extends CreateAdvertiseState {
  final String message;
  const CreateAdvertiseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CreateAdvertiseError extends CreateAdvertiseState {
  final String message;
  const CreateAdvertiseError(this.message);

  @override
  List<Object> get props => [message];
}
