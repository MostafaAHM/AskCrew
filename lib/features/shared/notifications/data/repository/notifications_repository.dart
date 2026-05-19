import 'package:dartz/dartz.dart';

import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/network/network_request.dart';
import 'package:aflam/core/network/network_service.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<String, List<NotificationModel>>> getAllNotifications();
  Future<Either<String, NotificationModel>> getNotificationById(int id);
  Future<Either<String, NotificationModel>> markNotificationRead(int id);
  Future<Either<String, void>> markAllNotificationsRead();
  Future<Either<String, void>> saveFcmToken(String token);
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NetworkService _networkService;

  NotificationsRepositoryImpl(this._networkService);

  @override
  Future<Either<String, List<NotificationModel>>> getAllNotifications() async {
    try {
      final request = NetworkRequest(
        AppUrls.getNotifications,
        method: RequestMethod.get,
      );

      final response = await _networkService.callApi(request);

      if (response is List) {
        final notifications = response
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        return Right(notifications);
      } else if (response is Map<String, dynamic> &&
          response['results'] is List) {
        final notifications = (response['results'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        return Right(notifications);
      }

      return const Right([]);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, NotificationModel>> getNotificationById(int id) async {
    try {
      final request = NetworkRequest(
        AppUrls.getNotificationById(id),
        method: RequestMethod.get,
      );

      final response = await _networkService.callApi(request);

      if (response is Map<String, dynamic>) {
        return Right(NotificationModel.fromJson(response));
      }

      return const Left('Invalid response');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, NotificationModel>> markNotificationRead(int id) async {
    try {
      final request = NetworkRequest(
        AppUrls.markNotificationRead(id),
        method: RequestMethod.post,
      );

      final response = await _networkService.callApi(request);

      if (response is Map<String, dynamic>) {
        return Right(NotificationModel.fromJson(response));
      }

      return const Left('Invalid response');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markAllNotificationsRead() async {
    try {
      final request = NetworkRequest(
        AppUrls.markAllNotificationsRead,
        method: RequestMethod.post,
      );

      await _networkService.callApi(request);

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveFcmToken(String token) async {
    try {
      final request = NetworkRequest(
        AppUrls.saveFcmToken,
        method: RequestMethod.post,
        body: {'fcm_token': token},
      );

      await _networkService.callApi(request);

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
