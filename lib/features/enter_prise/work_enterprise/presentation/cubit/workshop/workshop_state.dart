import 'package:equatable/equatable.dart';
import '../../../data/models/response/workshop_registration_model.dart';
import '../../../data/models/response/workshop_response_model.dart';

abstract class WorkshopState extends Equatable {
  const WorkshopState();

  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {
  const WorkshopInitial();
}

class WorkshopLoading extends WorkshopState {
  const WorkshopLoading();
}

class WorkshopListLoaded extends WorkshopState {
  final List<WorkshopResponseModel> workshops;
  final bool hasMore;

  const WorkshopListLoaded({
    required this.workshops,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [workshops, hasMore];
}

class WorkshopDetailsLoaded extends WorkshopState {
  final WorkshopResponseModel workshop;

  const WorkshopDetailsLoaded({
    required this.workshop,
  });

  @override
  List<Object?> get props => [workshop];
}

class WorkshopSuccess extends WorkshopState {
  final String message;
  final WorkshopResponseModel? workshop;

  const WorkshopSuccess({
    required this.message,
    this.workshop,
  });

  @override
  List<Object?> get props => [message, workshop];
}

class WorkshopDeleteSuccess extends WorkshopState {
  final String message;

  const WorkshopDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WorkshopError extends WorkshopState {
  final String message;
  final WorkshopResponseModel? workshop;

  const WorkshopError(this.message, {this.workshop});

  @override
  List<Object?> get props => [message, workshop];
}

class WorkshopApplySuccess extends WorkshopState {
  final String message;
  final WorkshopResponseModel workshop;

  const WorkshopApplySuccess({
    required this.message,
    required this.workshop,
  });

  @override
  List<Object?> get props => [message, workshop];
}

class WorkshopRegistrationActionSuccess extends WorkshopState {
  final String message;
  final WorkshopResponseModel workshop;

  const WorkshopRegistrationActionSuccess({
    required this.message,
    required this.workshop,
  });

  @override
  List<Object?> get props => [message, workshop];
}

class WorkshopRegistrationsLoaded extends WorkshopState {
  final List<WorkshopRegistrationModel> registrations;
  final WorkshopResponseModel? workshop;

  const WorkshopRegistrationsLoaded({
    required this.registrations,
    this.workshop,
  });

  @override
  List<Object?> get props => [registrations, workshop];
}

