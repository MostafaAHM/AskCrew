import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/network_request.dart';
import '../../../../../../core/repository/repository.dart';
import '../models/request/create_booking_item_request_model.dart';
import '../models/request/create_rent_request_model.dart';
import '../models/response/booking_item_response_model.dart';
import '../models/response/rent_request_response_model.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl extends Repository implements BookingRepository {
  @override
  Future<Either<CustomException, List<BookingItemResponseModel>>>
  getBookingItems({bool? mine, bool? suggested, List<String>? types}) async {
    final result = await exceptionHandler(() async {
      final queryParams = <String, dynamic>{};

      if (mine != null && mine) {
        queryParams['mine'] = 'true';
      }

      if (suggested != null && suggested) {
        queryParams['suggested'] = 'true';
      }

      if (types != null && types.isNotEmpty) {
        // If multiple types, send as comma-separated
        // If only one type, send it directly
        queryParams['type'] = types.length == 1 ? types.first : types.join(',');
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getBookingItems,
          method: RequestMethod.get,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic> && json.containsKey('results')) {
            final results = json['results'] as List<dynamic>? ?? [];
            return results
                .map(
                  (item) => BookingItemResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }

          if (json is List) {
            return json
                .map(
                  (item) => BookingItemResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return <BookingItemResponseModel>[];
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BookingItemResponseModel>> createBookingItem({
    required CreateBookingItemRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = await model.toFormData();

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.createBookingItem,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return BookingItemResponseModel.fromJson(json);
          } else if (json is Map) {
            return BookingItemResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception(
              'Invalid response format: expected Map, got ${json.runtimeType}',
            );
          }
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BookingItemResponseModel>> updateBookingItem({
    required int id,
    required CreateBookingItemRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = await model.toFormData();

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateBookingItem(id),
          method: RequestMethod.patch,
          formDataBody: formData,
          isFormData: true,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return BookingItemResponseModel.fromJson(json);
          } else if (json is Map) {
            return BookingItemResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception(
              'Invalid response format: expected Map, got ${json.runtimeType}',
            );
          }
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, void>> deleteBookingItem({
    required int id,
  }) async {
    final result = await exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.deleteBookingItem(id),
          method: RequestMethod.delete,
        ),
        mapper: (json) => null,
      );

      return;
    });
    return result;
  }

  @override
  Future<Either<CustomException, RentRequestResponseModel>> createRentRequest({
    required CreateRentRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final requestBody = model.toJson();
      // Ensure item is always included and is not null/0
      if (requestBody['item'] == null || requestBody['item'] == 0) {
        throw Exception('Item ID is required and must be a valid integer');
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.createBooking,
          method: RequestMethod.post,
          body: requestBody,
          headers: {'Content-Type': 'application/json'},
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return RentRequestResponseModel.fromJson(json);
          } else if (json is Map) {
            return RentRequestResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception(
              'Invalid response format: expected Map, got ${json.runtimeType}',
            );
          }
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, RentRequestResponseModel?>> getRentRequest({
    required int itemId,
  }) async {
    final result = await exceptionHandler(() async {
      try {
        // Get all bookings and find the one for this item
        final response = await dioService.callApi(
          NetworkRequest(AppUrls.getBookings, method: RequestMethod.get),
          mapper: (json) {
            debugPrint('getRentRequest - Looking for itemId: $itemId');
            debugPrint('getRentRequest - Response type: ${json.runtimeType}');

            List<RentRequestResponseModel> allBookings = [];

            if (json is List) {
              allBookings = json
                  .map(
                    (item) => RentRequestResponseModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();
            } else if (json is Map && json.containsKey('results')) {
              // Handle paginated response
              final results = json['results'] as List<dynamic>? ?? [];
              allBookings = results
                  .map(
                    (item) => RentRequestResponseModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();
            } else if (json is Map<String, dynamic>) {
              // If single booking returned
              allBookings = [RentRequestResponseModel.fromJson(json)];
            }

            debugPrint(
              'getRentRequest - Total bookings found: ${allBookings.length}',
            );
            for (var booking in allBookings) {
              debugPrint(
                'getRentRequest - Booking item: ${booking.item}, status: ${booking.status}',
              );
            }

            // Find booking for this item - use where to get all matching bookings, then take the first
            final matchingBookings = allBookings
                .where((b) => b.item == itemId)
                .toList();
            debugPrint(
              'getRentRequest - Matching bookings for item $itemId: ${matchingBookings.length}',
            );

            if (matchingBookings.isNotEmpty) {
              // Return the most recent booking (by created_at or updated_at)
              matchingBookings.sort((a, b) {
                final aDate = b.updatedAt ?? b.createdAt;
                final bDate = a.updatedAt ?? a.createdAt;
                return aDate.compareTo(bDate);
              });
              final selectedBooking = matchingBookings.first;
              debugPrint(
                'getRentRequest - Selected booking: id=${selectedBooking.id}, status=${selectedBooking.status}',
              );
              return selectedBooking;
            }

            debugPrint(
              'getRentRequest - No matching booking found for item $itemId',
            );
            return null;
          },
        );

        return response;
      } catch (e) {
        debugPrint('getRentRequest - Error: $e');
        // If no rent request exists, return null
        return null;
      }
    });
    return result;
  }

  @override
  Future<Either<CustomException, List<RentRequestResponseModel>>>
  getBookings() async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(AppUrls.getBookings, method: RequestMethod.get),
        mapper: (json) {
          if (json is List) {
            return json
                .map(
                  (item) => RentRequestResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else if (json is Map<String, dynamic> &&
              json.containsKey('results')) {
            final results = json['results'] as List<dynamic>? ?? [];
            return results
                .map(
                  (item) => RentRequestResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return <RentRequestResponseModel>[];
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, List<RentRequestResponseModel>>>
  getItemBookings({required int itemId}) async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getItemBookings(itemId),
          method: RequestMethod.get,
        ),
        mapper: (json) {
          if (json is List) {
            return json
                .map(
                  (item) => RentRequestResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          } else if (json is Map<String, dynamic> &&
              json.containsKey('results')) {
            final results = json['results'] as List<dynamic>? ?? [];
            return results
                .map(
                  (item) => RentRequestResponseModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return <RentRequestResponseModel>[];
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, RentRequestResponseModel>> getBookingById({
    required int id,
  }) async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(AppUrls.getBookingById(id), method: RequestMethod.get),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return RentRequestResponseModel.fromJson(json);
          } else if (json is Map) {
            return RentRequestResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception(
              'Invalid response format: expected Map, got ${json.runtimeType}',
            );
          }
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, RentRequestResponseModel>> updateBooking({
    required int id,
    required int itemId,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
    int? quantity,
  }) async {
    final result = await exceptionHandler(() async {
      final body = <String, dynamic>{'item': itemId, 'status': status};

      if (startDate != null) {
        body['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        body['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (quantity != null) {
        body['quantity'] = quantity;
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateBooking(id),
          method: RequestMethod.put,
          body: body,
          headers: {'Content-Type': 'application/json'},
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return RentRequestResponseModel.fromJson(json);
          } else if (json is Map) {
            return RentRequestResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception(
              'Invalid response format: expected Map, got ${json.runtimeType}',
            );
          }
        },
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, void>> deleteBooking({required int id}) async {
    final result = await exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(AppUrls.deleteBooking(id), method: RequestMethod.delete),
        mapper: (json) => null,
      );

      return;
    });
    return result;
  }

  @override
  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap({
        'to_user': toUserId,
        'rating': rating,
      });

      await dioService.callApi(
        NetworkRequest(
          AppUrls.rateUser,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
        ),
      );
    });
    return result;
  }
}
