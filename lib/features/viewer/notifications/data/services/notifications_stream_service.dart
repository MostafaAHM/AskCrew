import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/helpers/secure_local_storage.dart';

import '../models/notification_model.dart';

/// Service for handling Server-Sent Events (SSE) stream for real-time notifications
class NotificationsStreamService {
  StreamController<NotificationModel>? _controller;
  http.Client? _client;
  StreamSubscription? _streamSubscription;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  final int _maxReconnectDelay = 30; // seconds
  final Set<String> _seenNotificationIds = {};

  Stream<NotificationModel> get notificationStream {
    _controller ??= StreamController<NotificationModel>.broadcast(
      onCancel: () {
        dev.log('NotificationsStream: Stream cancelled');
      },
    );
    return _controller!.stream;
  }

  bool get isConnected => _isConnected;

  /// Start listening to the SSE stream
  Future<void> startListening() async {
    if (_isConnected) {
      dev.log('NotificationsStream: Already connected');
      return;
    }

    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) {
      dev.log('NotificationsStream: No token available, cannot connect');
      return;
    }

    _shouldReconnect = true;
    await _connect(token);
  }

  /// Stop listening to the SSE stream
  Future<void> stopListening() async {
    dev.log('NotificationsStream: Stopping stream');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _disconnect();
  }

  /// Connect to the SSE endpoint
  Future<void> _connect(String token) async {
    try {
      dev.log('NotificationsStream: Connecting to SSE endpoint');

      _client = http.Client();
      final url = AppUrls.notificationsStreamUrl(token);

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        _isConnected = true;
        _reconnectAttempts = 0;
        dev.log('NotificationsStream: Connected successfully');

        _streamSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleSseLine,
              onError: (error) {
                dev.log('NotificationsStream: Stream error: $error');
                _handleDisconnect();
              },
              onDone: () {
                dev.log('NotificationsStream: Stream closed by server');
                _handleDisconnect();
              },
              cancelOnError: false,
            );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        dev.log(
          'NotificationsStream: Authentication failed (${response.statusCode})',
        );
        _shouldReconnect = false;
        await _disconnect();
        // Trigger session expired flow - this will be handled by the cubit
        _controller?.addError('Authentication failed');
      } else {
        dev.log(
          'NotificationsStream: Connection failed with status ${response.statusCode}',
        );
        _handleDisconnect();
      }
    } catch (e) {
      dev.log('NotificationsStream: Connection error: $e');
      _handleDisconnect();
    }
  }

  /// Disconnect from the SSE endpoint
  Future<void> _disconnect() async {
    _isConnected = false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _client?.close();
    _client = null;
  }

  /// Handle disconnection and schedule reconnect
  void _handleDisconnect() {
    _disconnect();

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedule a reconnect with exponential backoff
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    final delay = _calculateReconnectDelay();
    dev.log('NotificationsStream: Reconnecting in $delay seconds...');

    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      final token = await SecureLocalStorage.read(PrefsKeys.token);
      if (token != null && token.isNotEmpty && _shouldReconnect) {
        await _connect(token);
      }
    });
  }

  /// Calculate reconnect delay with exponential backoff
  int _calculateReconnectDelay() {
    final delay = (1 << _reconnectAttempts).clamp(1, _maxReconnectDelay);
    _reconnectAttempts++;
    return delay;
  }

  // SSE parsing state
  String? _currentEvent;
  String? _currentId;
  final StringBuffer _dataBuffer = StringBuffer();

  /// Handle a single SSE line
  void _handleSseLine(String line) {
    // Empty line indicates end of event
    if (line.isEmpty) {
      _processEvent();
      return;
    }

    // Comment line (heartbeat) - ignore
    if (line.startsWith(':')) {
      return;
    }

    // Parse field
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      return;
    }

    final field = line.substring(0, colonIndex);
    var value = line.substring(colonIndex + 1);

    // Remove leading space if present
    if (value.startsWith(' ')) {
      value = value.substring(1);
    }

    switch (field) {
      case 'event':
        _currentEvent = value;
        break;
      case 'data':
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(value);
        break;
      case 'id':
        _currentId = value;
        break;
      case 'retry':
        // Could update reconnect delay based on server suggestion
        break;
    }
  }

  /// Process a complete SSE event
  void _processEvent() {
    if (_dataBuffer.isEmpty) {
      return;
    }

    try {
      final dataString = _dataBuffer.toString();
      _dataBuffer.clear();

      final json = jsonDecode(dataString) as Map<String, dynamic>;
      final notification = NotificationModel.fromJson(json);

      // Deduplicate notifications
      if (_seenNotificationIds.contains(notification.id)) {
        dev.log(
          'NotificationsStream: Duplicate notification ${notification.id}, ignoring',
        );
        return;
      }

      _seenNotificationIds.add(notification.id);

      // Keep only last 100 IDs to prevent memory leak
      if (_seenNotificationIds.length > 100) {
        final firstId = _seenNotificationIds.first;
        _seenNotificationIds.remove(firstId);
      }

      dev.log(
        'NotificationsStream: Received notification: ${notification.title}',
      );
      _controller?.add(notification);
    } catch (e) {
      dev.log('NotificationsStream: Error parsing notification: $e');
      // Don't crash on malformed JSON, just log and continue
    } finally {
      _currentEvent = null;
      _currentId = null;
    }
  }

  /// Dispose the service
  void dispose() {
    stopListening();
    _controller?.close();
    _controller = null;
    _seenNotificationIds.clear();
  }
}
