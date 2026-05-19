import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import '../../data/models/notification_model.dart';
import '../../data/repository/notifications_repository.dart';
import '../../data/services/notifications_stream_service.dart';
import '../../data/services/local_notifications_service.dart';
import 'package:aflam/core/helpers/secure_local_storage.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState>
    with WidgetsBindingObserver {
  final NotificationsStreamService _streamService;
  final NotificationsRepository _repository;
  final SharedPref _sharedPref;
  final LocalNotificationsService _localNotificationsService;

  StreamSubscription<NotificationModel>? _streamSubscription;
  final List<NotificationModel> _notifications = [];
  final Set<int> _readNotificationIds = {};
  static const int _maxCachedNotifications = 50;
  bool _isObserverAdded = false;

  NotificationsCubit(
    this._streamService,
    this._repository,
    this._sharedPref,
    this._localNotificationsService,
  ) : super(NotificationsInitial());

  /// Initialize notifications system
  Future<void> init() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) {
      dev.log('NotificationsCubit: No token found. Skipping init.');
      return;
    }

    if (!_isObserverAdded) {
      WidgetsBinding.instance.addObserver(this); // Life cycle management
      _isObserverAdded = true;
    }
    await _loadFromCache();
    await refreshFromApi();
    await startStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_streamService.isConnected) {
        // Optionally disconnect to save battery
        // In some cases keeping SSE alive is desired, but standard practice for "Foreground"
        // implies active usage. Let's disconnect.
        disconnectStream();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_streamService.isConnected) {
        startStream();
      }
    }
  }

  /// Load cached notifications and read status
  Future<void> _loadFromCache() async {
    try {
      emit(NotificationsLoading());

      // Load cached list
      final notificationsJson = _sharedPref.get(key: PrefsKeys.notifications);
      if (notificationsJson != null &&
          notificationsJson is String &&
          notificationsJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(notificationsJson);
        _notifications.clear();
        _notifications.addAll(
          jsonList.map((json) => NotificationModel.fromJson(json)).toList(),
        );
      }

      // Load read IDs
      final readStatusJson = _sharedPref.get(
        key: PrefsKeys.notificationsReadStatus,
      );
      if (readStatusJson != null &&
          readStatusJson is String &&
          readStatusJson.isNotEmpty) {
        final List<dynamic> readIds = jsonDecode(readStatusJson);
        _readNotificationIds.clear();
        _readNotificationIds.addAll(
          readIds.map((id) => int.parse(id.toString())),
        );
      } else {
        // Init read set from loaded models if they are read
        _readNotificationIds.clear();
        _readNotificationIds.addAll(
          _notifications.where((n) => n.isRead).map((n) => n.id),
        );
      }

      _emitLoadedState();
    } catch (e) {
      dev.log('NotificationsCubit: Error loading from cache: $e');
      // Use empty state if cache fails
      _notifications.clear();
      _emitLoadedState();
    }
  }

  /// Fetch latest notifications from REST API
  Future<void> refreshFromApi() async {
    if (state is NotificationsLoaded) {
      emit((state as NotificationsLoaded).copyWith(isRefreshing: true));
    } else {
      emit(NotificationsLoading());
    }

    final result = await _repository.getAllNotifications();
    result.fold(
      (error) {
        dev.log('NotificationsCubit: Error fetching API: $error');
        if (state is NotificationsLoaded) {
          emit((state as NotificationsLoaded).copyWith(isRefreshing: false));
        } else {
          emit(NotificationsError(error));
        }
      },
      (list) {
        _notifications.clear();
        _notifications.addAll(list);

        // Sort newest first
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Update read IDs based on fetched data
        _readNotificationIds.addAll(
          list.where((n) => n.isRead).map((n) => n.id),
        );

        _saveToCache();
        _emitLoadedState(isRefreshing: false);
      },
    );
  }

  /// Start SSE Stream
  Future<void> startStream() async {
    await _streamService.startListening();

    _streamSubscription?.cancel();
    _streamSubscription = _streamService.notificationStream.listen(
      (notification) {
        _handleIncomingNotification(notification);
      },
      onError: (error) {
        dev.log('NotificationsCubit: Stream error: $error');
      },
    );

    _emitLoadedState(isConnected: true);
  }

  Future<void> disconnectStream() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _streamService.stopListening();
    _emitLoadedState(isConnected: false);
  }

  void _handleIncomingNotification(NotificationModel notification) {
    // Show local notification
    _localNotificationsService.showNotification(notification);

    // Add to top
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);

      // Limit size
      if (_notifications.length > _maxCachedNotifications) {
        _notifications.removeRange(
          _maxCachedNotifications,
          _notifications.length,
        );
      }

      if (notification.isRead) {
        _readNotificationIds.add(notification.id);
      }

      _saveToCache();
      _emitLoadedState();
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(int id) async {
    if (_readNotificationIds.contains(id)) return;

    // Optimistic update
    _readNotificationIds.add(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    _emitLoadedState();
    // Save local state primarily to persist optimistic change
    await _saveReadStatus();
    await _saveToCache();

    // API Call
    final result = await _repository.markNotificationRead(id);
    result.fold(
      (error) {
        dev.log('NotificationsCubit: Mark read failed: $error');
        // Rollback on failure
        _readNotificationIds.remove(id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: false);
        }
        _emitLoadedState();
      },
      (updatedModel) {
        // Sync with backend model
        if (index != -1) {
          _notifications[index] = updatedModel;
        }
        // Persist confirmed state
        _saveToCache();
        _saveReadStatus();
        _emitLoadedState();
      },
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    // Optimistic update
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _readNotificationIds.add(_notifications[i].id);
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _emitLoadedState();
    await _saveReadStatus();
    await _saveToCache();

    // API Call
    final result = await _repository.markAllNotificationsRead();
    result.fold(
      (error) {
        dev.log('NotificationsCubit: Mark all read failed: $error');
        // On error, refresh from API to restore correct state
        refreshFromApi();
      },
      (_) {
        // Success
      },
    );
  }

  /// Delete notification locally (simulated)
  void deleteNotificationLocal(int id) {
    _notifications.removeWhere((n) => n.id == id);
    _readNotificationIds.remove(id); // Optional cleanup
    _saveToCache();
    _emitLoadedState();
  }

  int get unreadCount {
    return _notifications
        .where((n) => !_readNotificationIds.contains(n.id) && !n.isRead)
        .length;
  }

  Future<void> _saveToCache() async {
    try {
      final jsonList = _notifications
          .take(_maxCachedNotifications)
          .map((n) => n.toJson())
          .toList();
      await _sharedPref.set(
        key: PrefsKeys.notifications,
        value: jsonEncode(jsonList),
      );
    } catch (e) {
      dev.log('NotificationsCubit: cache save error: $e');
    }
  }

  Future<void> _saveReadStatus() async {
    try {
      await _sharedPref.set(
        key: PrefsKeys.notificationsReadStatus,
        value: jsonEncode(_readNotificationIds.toList()),
      );
    } catch (e) {
      dev.log('NotificationsCubit: read status save error: $e');
    }
  }

  void _emitLoadedState({bool? isConnected, bool? isRefreshing}) {
    final count = _notifications
        .where((n) => !_readNotificationIds.contains(n.id) && !n.isRead)
        .length;

    emit(
      NotificationsLoaded(
        notifications: List.unmodifiable(_notifications),
        unreadCount: count,
        isConnected: isConnected ?? _streamService.isConnected,
        isRefreshing:
            isRefreshing ??
            (state is NotificationsLoaded
                ? (state as NotificationsLoaded).isRefreshing
                : false),
      ),
    );
  }

  Future<void> clearOnLogout() async {
    await disconnectStream();
    _notifications.clear();
    _readNotificationIds.clear();
    emit(NotificationsInitial());

    await _sharedPref.remove(key: PrefsKeys.notifications);
    await _sharedPref.remove(key: PrefsKeys.notificationsReadStatus);

    if (_isObserverAdded) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserverAdded = false;
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
