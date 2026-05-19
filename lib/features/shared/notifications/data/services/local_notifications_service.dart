import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/config/routes/app_router.dart';
import 'dart:developer' as dev;

import '../models/notification_model.dart';

class LocalNotificationsService {
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  factory LocalNotificationsService() {
    return _instance;
  }

  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications.';

  // Deduplication cache (LRU-like via fixed size list/set)
  final Set<String> _processedNotificationKeys = {};

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (Platform.isAndroid) {
      await _createNotificationChannel();
      await _requestPermissions();
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification(NotificationModel notification) async {
    // 1. Deduplication logic
    final key =
        '${notification.id}_${notification.createdAt.millisecondsSinceEpoch}';
    if (_processedNotificationKeys.contains(key)) {
      // Double check using ID if > 0 as per requirements
      if (notification.id > 0 &&
          _processedNotificationKeys.any(
            (k) => k.startsWith('${notification.id}_'),
          )) {
        // Already processed this ID
        dev.log(
          "LocalNotificationsService: Duplicate notification suppressed (ID: ${notification.id})",
        );
        return;
      }

      // Fallback de-dupe for 0 IDs
      if (notification.id == 0) {
        final fallbackKey =
            '${notification.notificationType}_${notification.title}_${notification.message}_${notification.createdAt.millisecondsSinceEpoch}';
        if (_processedNotificationKeys.contains(fallbackKey)) {
          dev.log(
            "LocalNotificationsService: Duplicate notification suppressed (Fallback key)",
          );
          return;
        }
        _addToCache(fallbackKey);
      } else {
        _addToCache(key);
      }
    } else {
      _addToCache(key);
    }

    // 2. Prepare content
    String title = notification.title;
    if (title.isEmpty) {
      title = notification.notificationType.isNotEmpty
          ? notification.notificationType
          : 'New Notification';
    }

    String body = notification.message;
    if (body.isEmpty) {
      body = 'Tap to open';
    }

    // 3. Show
    try {
      await flutterLocalNotificationsPlugin.show(
        // Use a unique ID based on timestamp or something unique if ID is 0
        // But notification.id is ideal if unique. If 0 (e.g. system msg), use timestamp.
        notification.id > 0
            ? notification.id
            : DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
          ),
        ),
        payload: jsonEncode(notification.toJson()),
      );
    } catch (e) {
      dev.log("LocalNotificationsService: Error showing notification: $e");
    }
  }

  void _addToCache(String key) {
    if (_processedNotificationKeys.length >= 200) {
      _processedNotificationKeys.remove(_processedNotificationKeys.first);
    }
    _processedNotificationKeys.add(key);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final json = jsonDecode(response.payload!);
        final notification = NotificationModel.fromJson(json);
        handleRedirection(notification);
      } catch (e) {
        dev.log("LocalNotificationsService: Payload decode error: $e");
      }
    }
  }

  void handleRedirection(NotificationModel notification) {
    // This requires a context or a navigator key.
    // Since this is a service, we rely on AppRouter.appNavigatorKey

    final context = AppRouter.appNavigatorKey.currentContext;
    if (context == null) return;

    if (notification.notificationType == 'chat') {
      // Extract room ID from metadata or fallback
      // metadata might look like { 'room_id': 123 }
      final roomId = notification.metadata['room_id'] is int
          ? notification.metadata['room_id']
          : int.tryParse(notification.metadata['room_id'].toString());

      if (roomId != null) {
        GoRouter.of(context).pushNamed(
          Routes.chatMessages,
          pathParameters: {'roomId': roomId.toString()},
          extra: {
            'roomName': notification.title,
          }, // Pass title as room name fallback
        );
        return;
      }
    }

    // Default fallback
    GoRouter.of(context).pushNamed(Routes.notifications);
  }
}
