import 'package:dartz/dartz.dart';
import '../../../../../../core/error/exceptions.dart';
import '../models/request/create_booking_item_request_model.dart';
import '../models/request/create_rent_request_model.dart';
import '../models/response/booking_item_response_model.dart';
import '../models/response/rent_request_response_model.dart';

abstract class BookingRepository {
  Future<Either<CustomException, List<BookingItemResponseModel>>>
  getBookingItems({bool? mine, bool? suggested, List<String>? types});

  Future<Either<CustomException, BookingItemResponseModel>> createBookingItem({
    required CreateBookingItemRequestModel model,
  });

  Future<Either<CustomException, BookingItemResponseModel>> updateBookingItem({
    required int id,
    required CreateBookingItemRequestModel model,
  });

  Future<Either<CustomException, void>> deleteBookingItem({required int id});

  Future<Either<CustomException, RentRequestResponseModel>> createRentRequest({
    required CreateRentRequestModel model,
  });

  Future<Either<CustomException, RentRequestResponseModel?>> getRentRequest({
    required int itemId,
  });

  // New booking endpoints
  Future<Either<CustomException, List<RentRequestResponseModel>>> getBookings();

  Future<Either<CustomException, List<RentRequestResponseModel>>>
  getItemBookings({required int itemId});

  Future<Either<CustomException, RentRequestResponseModel>> getBookingById({
    required int id,
  });

  Future<Either<CustomException, RentRequestResponseModel>> updateBooking({
    required int id,
    required int itemId,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    int? quantity,
  });

  Future<Either<CustomException, void>> deleteBooking({required int id});

  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  });
}
