import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/create_workshop_request_model.dart';

import '../../../data/models/response/workshop_response_model.dart';
import '../../../data/repository/workshop/workshop_repository.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState> {
  final WorkshopRepository _repository;
  int _page = 1;
  int _myPage = 1;
  bool _isFetching = false;

  WorkshopCubit(this._repository) : super(const WorkshopInitial());

  Future<void> getWorkshops({bool refresh = false, bool isMyWorkshops = false}) async {
    if (_isFetching) return;
    if (refresh) {
      if (isMyWorkshops) {
        _myPage = 1;
      } else {
        _page = 1;
      }
      emit(const WorkshopLoading());
    }

    _isFetching = true;
    
    final result = isMyWorkshops
        ? await _repository.getMyWorkshops(page: _myPage, pageSize: 100)
        : await _repository.getWorkshops(page: _page, pageSize: 100);
    _isFetching = false;

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) {
        if (refresh) {
          emit(WorkshopListLoaded(
            workshops: response.results,
            hasMore: response.next != null,
          ));
        } else {
          final currentState = state;
          if (currentState is WorkshopListLoaded) {
            final currentIds = currentState.workshops.map((w) => w.id).toSet();
            final newWorkshops = response.results
                .where((w) => !currentIds.contains(w.id))
                .toList();
            emit(WorkshopListLoaded(
              workshops: currentState.workshops + newWorkshops,
              hasMore: response.next != null,
            ));
          } else {
            emit(WorkshopListLoaded(
              workshops: response.results,
              hasMore: response.next != null,
            ));
          }
        }
        if (response.next != null) {
          if (isMyWorkshops) {
            _myPage++;
          } else {
            _page++;
          }
        }
      },
    );
  }

  void removeWorkshop(int id) {
    final currentState = state;
    if (currentState is WorkshopListLoaded) {
      final updatedWorkshops =
          currentState.workshops.where((w) => w.id != id).toList();
      emit(WorkshopListLoaded(
        workshops: updatedWorkshops,
        hasMore: currentState.hasMore,
      ));
    }
  }

  Future<void> getWorkshopById(int id) async {
    emit(const WorkshopLoading());

    final result = await _repository.getWorkshopById(id: id);

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopDetailsLoaded(workshop: response)),
    );
  }

  Future<void> createWorkshop(CreateWorkshopRequestModel model) async {
    emit(const WorkshopLoading());

    final result = await _repository.createWorkshop(model: model);

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopSuccess(
        message: 'Workshop created successfully!',
        workshop: response,
      )),
    );
  }

  Future<void> updateWorkshop({
    required int id,
    required CreateWorkshopRequestModel model,
  }) async {
    emit(const WorkshopLoading());

    final result = await _repository.updateWorkshop(id: id, model: model);

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopSuccess(
        message: 'Workshop updated successfully!',
        workshop: response,
      )),
    );
  }

  Future<void> deleteWorkshop(int id) async {
    // Remove from list immediately (optimistic update)
    final currentState = state;
    List<WorkshopResponseModel>? updatedWorkshops;
    bool? hasMore;
    
    if (currentState is WorkshopListLoaded) {
      updatedWorkshops =
          currentState.workshops.where((w) => w.id != id).toList();
      hasMore = currentState.hasMore;
      emit(WorkshopListLoaded(
        workshops: updatedWorkshops,
        hasMore: hasMore,
      ));
    }

    // Delete from server in background
    final result = await _repository.deleteWorkshop(id: id);

    result.fold(
      (error) {
        // If error, restore the list by refreshing
        if (currentState is WorkshopListLoaded) {
          getWorkshops(refresh: true);
        }
        emit(WorkshopError(error.toString()));
      },
      (_) {
        // After successful delete, keep the list state
        // Emit delete success for listener to show message
        emit(const WorkshopDeleteSuccess('Workshop deleted successfully!'));
        // Immediately restore list state so UI doesn't break
        if (updatedWorkshops != null && hasMore != null) {
          emit(WorkshopListLoaded(
            workshops: updatedWorkshops,
            hasMore: hasMore,
          ));
        }
      },
    );
  }

  Future<void> applyToWorkshop(int workshopId) async {
    final result = await _repository.applyToWorkshop(workshopId: workshopId);

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopApplySuccess(
        message: 'Application submitted successfully!',
        workshop: response,
      )),
    );
  }

  Future<void> approveWorkshopRegistration(int registrationId) async {
    final result = await _repository.approveWorkshopRegistration(
      registrationId: registrationId,
    );

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopRegistrationActionSuccess(
        message: 'Application approved successfully!',
        workshop: response,
      )),
    );
  }

  Future<void> rejectWorkshopRegistration(int registrationId) async {
    final result = await _repository.rejectWorkshopRegistration(
      registrationId: registrationId,
    );

    result.fold(
      (error) => emit(WorkshopError(error.toString())),
      (response) => emit(WorkshopRegistrationActionSuccess(
        message: 'Application rejected successfully!',
        workshop: response,
      )),
    );
  }

  Future<void> getWorkshopRegistrations(int workshopId) async {
    // Preserve current workshop state
    WorkshopResponseModel? currentWorkshop;
    if (state is WorkshopDetailsLoaded) {
      currentWorkshop = (state as WorkshopDetailsLoaded).workshop;
    } else if (state is WorkshopRegistrationsLoaded) {
      currentWorkshop = (state as WorkshopRegistrationsLoaded).workshop;
    } else if (state is WorkshopError) {
      currentWorkshop = (state as WorkshopError).workshop;
    }

    final result = await _repository.getWorkshopRegistrations(workshopId: workshopId);

    result.fold(
      (error) => emit(WorkshopError(error.toString(), workshop: currentWorkshop)),
      (registrations) => emit(WorkshopRegistrationsLoaded(
        registrations: registrations,
        workshop: currentWorkshop,
      )),
    );
  }

  Future<void> rateUser({
    required int toUserId,
    required int rating,
  }) async {
    WorkshopResponseModel? currentWorkshop;
    if (state is WorkshopDetailsLoaded) {
      currentWorkshop = (state as WorkshopDetailsLoaded).workshop;
    } else if (state is WorkshopRegistrationsLoaded) {
      currentWorkshop = (state as WorkshopRegistrationsLoaded).workshop;
    } else if (state is WorkshopError) {
      currentWorkshop = (state as WorkshopError).workshop;
    }

    final result = await _repository.rateUser(
      toUserId: toUserId,
      rating: rating,
    );

    result.fold(
      (error) => emit(WorkshopError(error.toString(), workshop: currentWorkshop)),
      (_) => emit(WorkshopSuccess(
        message: 'Rating submitted successfully!',
        workshop: currentWorkshop,
      )),
    );
  }

  void reset() {
    emit(const WorkshopInitial());
  }
}

