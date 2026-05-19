import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request/create_booking_item_request_model.dart';
import '../../data/models/request/create_rent_request_model.dart';
import '../../data/models/response/booking_item_response_model.dart';
import '../../data/repository/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit(this._repository) : super(const BookingInitial());

  Future<void> getBookingItems({
    bool refresh = false,
    bool? mine,
    bool? suggested,
    List<String>? types,
  }) async {
    if (refresh) {
      emit(const BookingLoading());
    }

    final result = await _repository.getBookingItems(
      mine: mine,
      suggested: suggested,
      types: types,
    );

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (items) => emit(BookingListLoaded(items: items)),
    );
  }

  Future<void> createBookingItem(CreateBookingItemRequestModel model) async {
    emit(const BookingLoading());

    final result = await _repository.createBookingItem(model: model);

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (response) => emit(
        BookingSuccess(
          message: 'Booking item created successfully!',
          item: response,
        ),
      ),
    );
  }

  Future<void> updateBookingItem({
    required int id,
    required CreateBookingItemRequestModel model,
  }) async {
    emit(const BookingLoading());

    final result = await _repository.updateBookingItem(id: id, model: model);

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (response) => emit(
        BookingSuccess(
          message: 'Booking item updated successfully!',
          item: response,
        ),
      ),
    );
  }

  Future<void> deleteBookingItem(int id) async {
    // Remove from list immediately (optimistic update)
    final currentState = state;
    List<BookingItemResponseModel>? updatedItems;

    if (currentState is BookingListLoaded) {
      updatedItems = currentState.items.where((item) => item.id != id).toList();
      emit(BookingListLoaded(items: updatedItems));
    }

    // Delete from server in background
    final result = await _repository.deleteBookingItem(id: id);

    result.fold(
      (error) {
        // Revert on error
        if (currentState is BookingListLoaded) {
          emit(BookingListLoaded(items: currentState.items));
        }
        emit(BookingError(error.toString()));
      },
      (_) {
        if (currentState is BookingListLoaded && updatedItems != null) {
          emit(BookingListLoaded(items: updatedItems));
        } else {
          emit(
            const BookingDeleteSuccess('Booking item deleted successfully!'),
          );
        }
      },
    );
  }

  void removeBookingItem(int id) {
    final currentState = state;
    if (currentState is BookingListLoaded) {
      final updatedItems = currentState.items
          .where((item) => item.id != id)
          .toList();
      emit(BookingListLoaded(items: updatedItems));
    }
  }

  Future<void> createRentRequest(
    int itemId, {
    String? name,
    String? message,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
  }) async {
    emit(const RentRequestLoading());

    final result = await _repository.createRentRequest(
      model: CreateRentRequestModel(
        itemId: itemId,
        name: name,
        message: message,
        startDate: startDate,
        endDate: endDate,
        quantity: quantity,
      ),
    );

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (rentRequest) => emit(
        RentRequestSuccess(
          message: 'Rent request sent successfully!',
          rentRequest: rentRequest,
        ),
      ),
    );
  }

  Future<void> getRentRequest(int itemId) async {
    emit(const RentRequestLoading());

    final result = await _repository.getRentRequest(itemId: itemId);

    result.fold((error) => emit(BookingError(error.toString())), (rentRequest) {
      if (rentRequest != null) {
        emit(RentRequestLoaded(rentRequest: rentRequest));
      } else {
        emit(const BookingInitial());
      }
    });
  }

  Future<void> getBookings() async {
    emit(const BookingLoading());

    final result = await _repository.getBookings();

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (bookings) => emit(BookingsListLoaded(bookings: bookings)),
    );
  }

  Future<void> getItemBookings(int itemId) async {
    emit(const BookingLoading());

    final result = await _repository.getItemBookings(itemId: itemId);

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (bookings) => emit(BookingsListLoaded(bookings: bookings)),
    );
  }

  Future<void> getBookingById(int id) async {
    emit(const RentRequestLoading());

    final result = await _repository.getBookingById(id: id);

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (booking) => emit(RentRequestLoaded(rentRequest: booking)),
    );
  }

  Future<void> updateBooking({
    required int id,
    required int itemId,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    int? quantity,
  }) async {
    emit(const RentRequestLoading());

    final result = await _repository.updateBooking(
      id: id,
      itemId: itemId,
      status: status,
      startDate: startDate,
      endDate: endDate,
      quantity: quantity,
    );

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (booking) => emit(
        RentRequestSuccess(
          message: 'Booking updated successfully!',
          rentRequest: booking,
        ),
      ),
    );
  }

  Future<void> deleteBooking(int id) async {
    emit(const BookingLoading());

    final result = await _repository.deleteBooking(id: id);

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (_) => emit(const BookingDeleteSuccess('Booking deleted successfully!')),
    );
  }

  Future<void> rateUser({required int toUserId, required int rating}) async {
    final result = await _repository.rateUser(
      toUserId: toUserId,
      rating: rating,
    );

    result.fold(
      (error) => emit(BookingError(error.toString())),
      (_) =>
          emit(const BookingSuccess(message: 'Rating submitted successfully!')),
    );
  }
}
