import 'dart:developer' as dev;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repository/notifications_repository.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'local_notifications_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  dev.log('FCM: Background message received: ${message.messageId}');
  dev.log(
    'FCM: If message has "notification" field, FCM displays it automatically',
  );
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationsService _localNotificationsService =
      LocalNotificationsService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    try {
      dev.log('FCM: Initializing FCM service');

      await _requestPermissions();
      await _getToken();
      await _setupForegroundNotifications();
      await _setupBackgroundNotifications();
      await _setupNotificationInteractions();

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        dev.log('FCM: Token refreshed: $newToken');
        _onTokenRefresh(newToken);
      });

      dev.log('FCM: Service initialized successfully');
    } catch (e) {
      dev.log('FCM: Error initializing service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    dev.log('FCM: User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      dev.log('FCM: Token obtained: $_fcmToken');
      if (_fcmToken != null) {
        await _onTokenReceived(_fcmToken!);
      }
    } catch (e) {
      dev.log('FCM: Error getting token: $e');
    }
  }

  Future<void> _setupForegroundNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log('FCM: Received foreground message: ${message.messageId}');

      if (message.notification != null) {
        dev.log(
          'FCM: Notification title: ${message.notification?.title}, body: ${message.notification?.body}',
        );
      }

      final notification = _convertRemoteMessageToNotificationModel(message);
      _localNotificationsService.showNotification(notification);
    });
  }

  Future<void> _setupBackgroundNotifications() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _setupNotificationInteractions() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();

    if (initialMessage != null) {
      dev.log('FCM: App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log('FCM: App opened from background via notification');
      _handleNotificationTap(message);
    });
  }

  NotificationModel _convertRemoteMessageToNotificationModel(
    RemoteMessage message,
  ) {
    final data = message.data;
    final notification = message.notification;

    return NotificationModel(
      id:
          int.tryParse(data['id']?.toString() ?? '') ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification?.title ?? data['title'] ?? 'New Notification',
      message: notification?.body ?? data['message'] ?? data['body'] ?? '',
      notificationType: data['type'] ?? data['notification_type'] ?? 'general',
      createdAt: DateTime.now(),
      isRead: false,
      metadata: Map<String, dynamic>.from(data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final notification = _convertRemoteMessageToNotificationModel(message);
    _localNotificationsService.handleRedirection(notification);
  }

  Future<void> _onTokenReceived(String token) async {
    dev.log('FCM: Token received - sending to backend: $token');
    try {
      final repository = getIt<NotificationsRepository>();
      await repository.saveFcmToken(token);
      dev.log('FCM: Token sent to backend successfully');
    } catch (e) {
      dev.log('FCM: Error sending token to backend: $e');
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    dev.log('FCM: Token refreshed - sending to backend: $token');
    try {
      final repository = getIt<NotificationsRepository>();
      await repository.saveFcmToken(token);
      dev.log('FCM: Token sent to backend successfully');
    } catch (e) {
      dev.log('FCM: Error sending token to backend: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      dev.log('FCM: Subscribed to topic: $topic');
    } catch (e) {
      dev.log('FCM: Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      dev.log('FCM: Unsubscribed from topic: $topic');
    } catch (e) {
      dev.log('FCM: Error unsubscribing from topic: $e');
    }
  }
}
