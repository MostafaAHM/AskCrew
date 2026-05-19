import 'package:equatable/equatable.dart';
import '../../data/models/response/booking_item_response_model.dart';
import '../../data/models/response/rent_request_response_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingListLoaded extends BookingState {
  final List<BookingItemResponseModel> items;

  const BookingListLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class BookingSuccess extends BookingState {
  final String message;
  final BookingItemResponseModel? item;

  const BookingSuccess({required this.message, this.item});

  @override
  List<Object?> get props => [message, item];
}

class BookingDeleteSuccess extends BookingState {
  final String message;

  const BookingDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class RentRequestLoading extends BookingState {
  const RentRequestLoading();
}

class RentRequestLoaded extends BookingState {
  final RentRequestResponseModel rentRequest;

  const RentRequestLoaded({required this.rentRequest});

  @override
  List<Object?> get props => [rentRequest];
}

class RentRequestSuccess extends BookingState {
  final String message;
  final RentRequestResponseModel rentRequest;

  const RentRequestSuccess({required this.message, required this.rentRequest});

  @override
  List<Object?> get props => [message, rentRequest];
}

class BookingsListLoaded extends BookingState {
  final List<RentRequestResponseModel> bookings;

  const BookingsListLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}
