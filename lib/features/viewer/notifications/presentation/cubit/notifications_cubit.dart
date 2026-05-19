import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aflam/core/di/service_locator.dart';

import '../../../../../core/app_config/prefs_keys.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notifications_stream_service.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsStreamService _streamService;
  StreamSubscription<NotificationModel>? _notificationSubscription;
  final List<NotificationModel> _notifications = [];
  final Set<String> _readNotificationIds = {};
  static const int _maxNotifications = 50;

  NotificationsCubit(this._streamService) : super(NotificationsInitial()) {
    _loadFromCache();
  }

  /// Load cached notifications and read status from local storage
  Future<void> _loadFromCache() async {
    try {
      emit(NotificationsLoading());

      // Load notifications from cache
      // Load notifications from cache
      final notificationsJson =
          getIt<SharedPref>().get(key: PrefsKeys.notifications) as String?;
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(notificationsJson);
        _notifications.clear();
        _notifications.addAll(
          jsonList
              .map(
                (json) =>
                    NotificationModel.fromJson(json as Map<String, dynamic>),
              )
              .toList(),
        );
      }

      // Load read status
      final readStatusJson =
          getIt<SharedPref>().get(key: PrefsKeys.notificationsReadStatus)
              as String?;
      if (readStatusJson != null && readStatusJson.isNotEmpty) {
        final List<dynamic> readIds = jsonDecode(readStatusJson);
        _readNotificationIds.clear();
        _readNotificationIds.addAll(readIds.map((id) => id.toString()));
      }

      _emitLoadedState();
    } catch (e) {
      dev.log('NotificationsCubit: Error loading from cache: $e');
      emit(const NotificationsError('Failed to load notifications'));
    }
  }

  /// Start listening to the notification stream
  Future<void> startListening() async {
    try {
      dev.log('NotificationsCubit: Starting to listen for notifications');

      // Start the SSE stream
      await _streamService.startListening();

      // Subscribe to notifications
      _notificationSubscription?.cancel();
      _notificationSubscription = _streamService.notificationStream.listen(
        (notification) {
          _handleNewNotification(notification);
        },
        onError: (error) {
          dev.log('NotificationsCubit: Stream error: $error');
          if (error.toString().contains('Authentication failed')) {
            emit(const NotificationsError('Session expired'));
          }
        },
      );

      _emitLoadedState(isConnected: true);
    } catch (e) {
      dev.log('NotificationsCubit: Error starting listener: $e');
      emit(NotificationsError('Failed to connect: ${e.toString()}'));
    }
  }

  /// Stop listening to the notification stream
  Future<void> stopListening() async {
    dev.log('NotificationsCubit: Stopping listener');
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    await _streamService.stopListening();
    _emitLoadedState(isConnected: false);
  }

  /// Handle a new notification from the stream
  void _handleNewNotification(NotificationModel notification) {
    dev.log(
      'NotificationsCubit: New notification received: ${notification.title}',
    );

    // Add to the beginning of the list (latest first)
    _notifications.insert(0, notification);

    // Keep only the last N notifications
    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(_maxNotifications, _notifications.length);
    }

    // Save to cache
    _saveToCache();

    // Emit new state
    _emitLoadedState(isConnected: _streamService.isConnected);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_readNotificationIds.contains(notificationId)) {
      return;
    }

    _readNotificationIds.add(notificationId);
    await _saveReadStatus();
    _emitLoadedState(isConnected: _streamService.isConnected);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _readNotificationIds.clear();
    _readNotificationIds.addAll(_notifications.map((n) => n.id));
    await _saveReadStatus();
    _emitLoadedState(isConnected: _streamService.isConnected);
  }

  /// Check if a notification is read
  bool isRead(String notificationId) {
    return _readNotificationIds.contains(notificationId);
  }

  /// Get unread count
  int get unreadCount {
    return _notifications
        .where((n) => !_readNotificationIds.contains(n.id))
        .length;
  }

  /// Save notifications to cache
  Future<void> _saveToCache() async {
    try {
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await getIt<SharedPref>().set(
        key: PrefsKeys.notifications,
        value: jsonString,
      );
    } catch (e) {
      dev.log('NotificationsCubit: Error saving to cache: $e');
    }
  }

  /// Save read status to cache
  Future<void> _saveReadStatus() async {
    try {
      final jsonString = jsonEncode(_readNotificationIds.toList());
      await getIt<SharedPref>().set(
        key: PrefsKeys.notificationsReadStatus,
        value: jsonString,
      );
    } catch (e) {
      dev.log('NotificationsCubit: Error saving read status: $e');
    }
  }

  /// Emit loaded state with current data
  void _emitLoadedState({bool? isConnected}) {
    emit(
      NotificationsLoaded(
        notifications: List.unmodifiable(_notifications),
        unreadCount: unreadCount,
        isConnected: isConnected ?? _streamService.isConnected,
      ),
    );
  }

  /// Refresh notifications (reconnect)
  Future<void> refresh() async {
    await stopListening();
    await Future.delayed(const Duration(milliseconds: 500));
    await startListening();
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _streamService.dispose();
    return super.close();
  }
}
