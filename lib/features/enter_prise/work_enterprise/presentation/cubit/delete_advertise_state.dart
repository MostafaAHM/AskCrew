import 'package:equatable/equatable.dart';

abstract class DeleteAdvertiseState extends Equatable {
  const DeleteAdvertiseState();

  @override
  List<Object> get props => [];
}

class DeleteAdvertiseInitial extends DeleteAdvertiseState {
  const DeleteAdvertiseInitial();
}

class DeleteAdvertiseLoading extends DeleteAdvertiseState {
  const DeleteAdvertiseLoading();
}

class DeleteAdvertiseSuccess extends DeleteAdvertiseState {
  final String message;
  const DeleteAdvertiseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteAdvertiseError extends DeleteAdvertiseState {
  final String message;
  const DeleteAdvertiseError(this.message);

  @override
  List<Object> get props => [message];
}
