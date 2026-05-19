import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:aflam/core/helpers/secure_local_storage.dart';
import '../models/notification_model.dart';

/// Service for handling Server-Sent Events (SSE) stream for real-time notifications
class NotificationsStreamService {
  StreamController<NotificationModel>? _controller;
  http.Client? _client;
  StreamSubscription? _streamSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  final int _maxReconnectDelay = 30; // seconds
  final int _heartbeatTimeout = 45; // seconds

  String? _lastEventId;
  final Set<int> _seenNotificationIds = {};

  // SSE parsing state
  final StringBuffer _dataBuffer = StringBuffer();
  String? _currentEventName;

  Stream<NotificationModel> get notificationStream {
    _controller ??= StreamController<NotificationModel>.broadcast(
      onListen: () {
        dev.log('NotificationsStream: Listener subscribed');
        if (!_isConnected) startListening();
      },
      onCancel: () {
        dev.log('NotificationsStream: Stream cancelled');
        stopListening();
      },
    );
    return _controller!.stream;
  }

  bool get isConnected => _isConnected;

  /// Start listening to the SSE stream
  Future<void> startListening() async {
    if (_isConnected) return;

    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) {
      dev.log('NotificationsStream: No token available, cannot connect');
      return;
    }

    _shouldReconnect = true;
    _scheduleReconnect(immediate: true);
  }

  /// Stop listening to the SSE stream
  Future<void> stopListening() async {
    dev.log('NotificationsStream: Stopping stream');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopHeartbeatMonitor();
    await _disconnect();
  }

  /// Connect to the SSE endpoint
  Future<void> _connect(String token) async {
    try {
      dev.log('NotificationsStream: Connecting to SSE endpoint');

      _client = http.Client();
      // Using URL param as per existing pattern, but adding Bearer header is best practice if supported
      final url = AppUrls.notificationsStreamUrl(token);

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      });

      if (_lastEventId != null) {
        request.headers['Last-Event-ID'] = _lastEventId!;
      }

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        _isConnected = true;
        _reconnectAttempts = 0;
        _startHeartbeatMonitor(); // Start watching for staleness
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
        // Trigger session expired
        _controller?.addError('Authentication failed');
      } else {
        dev.log(
          'NotificationsStream: Connection failed with status ${response.statusCode}',
        );
        // Verify if 204 No Content (sometimes used for "no events yet")
        if (response.statusCode == 204) {
          _handleDisconnect(); // Treat as disconnect, reconnect after delay
        } else {
          _handleDisconnect();
        }
      }
    } catch (e) {
      dev.log('NotificationsStream: Connection error: $e');
      _handleDisconnect();
    }
  }

  /// Disconnect from the SSE endpoint
  Future<void> _disconnect() async {
    _isConnected = false;
    _stopHeartbeatMonitor();
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _client?.close();
    _client = null;
    _dataBuffer.clear();
    _currentEventName = null;
  }

  /// Handle disconnection and schedule reconnect
  void _handleDisconnect() {
    _disconnect();
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedule a reconnect with exponential backoff
  void _scheduleReconnect({bool immediate = false}) {
    _reconnectTimer?.cancel();

    if (immediate) {
      _attemptReconnect();
      return;
    }

    final delay = _calculateReconnectDelay();
    dev.log('NotificationsStream: Reconnecting in $delay seconds...');

    _reconnectTimer = Timer(Duration(seconds: delay), _attemptReconnect);
  }

  Future<void> _attemptReconnect() async {
    if (!_shouldReconnect) return;

    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token != null && token.isNotEmpty) {
      await _connect(token);
    }
  }

  /// Calculate reconnect delay with exponential backoff
  int _calculateReconnectDelay() {
    final delay = (1 << _reconnectAttempts).clamp(1, _maxReconnectDelay);
    _reconnectAttempts++;
    return delay;
  }

  // --- Heartbeat & Staleness ---

  void _startHeartbeatMonitor() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer(Duration(seconds: _heartbeatTimeout), () {
      dev.log(
        'NotificationsStream: Connection stale (no heartbeat), reconnecting...',
      );
      _handleDisconnect();
    });
  }

  void _resetHeartbeatMonitor() {
    if (_isConnected) {
      _startHeartbeatMonitor();
    }
  }

  void _stopHeartbeatMonitor() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // --- Parsing ---

  /// Handle a single SSE line
  void _handleSseLine(String line) {
    _resetHeartbeatMonitor(); // Activity detected

    if (line.isEmpty) {
      // Empty line -> Dispatch event
      _processEvent();
      return;
    }

    // Comment/Heartbeat
    if (line.startsWith(':')) {
      return;
    }

    final colonIndex = line.indexOf(':');
    String field = line;
    String value = '';

    if (colonIndex != -1) {
      field = line.substring(0, colonIndex);
      value = line.substring(colonIndex + 1);
      if (value.startsWith(' ')) {
        value = value.substring(1);
      }
    }

    switch (field) {
      case 'id':
        _lastEventId = value;
        break;
      case 'event':
        _currentEventName = value;
        break;
      case 'data':
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(value);
        break;
      case 'retry':
        // Optional: Parse retry time
        break;
    }
  }

  /// Process a complete SSE event
  void _processEvent() {
    if (_dataBuffer.isEmpty) {
      // Sometimes just event or id updates
      return;
    }

    try {
      final dataString = _dataBuffer.toString();
      _dataBuffer.clear();

      // If event is 'ping' or similar, ignore body if empty
      // But usually 'data' implies payload.

      if (_currentEventName == 'ping' || _currentEventName == 'heartbeat') {
        return;
      }

      final json = jsonDecode(dataString);

      if (json is! Map<String, dynamic>) {
        dev.log('NotificationsStream: Unexpected data format (not map)');
        return;
      }

      // Map JSON to NotificationModel
      final notification = NotificationModel.fromJson(json);

      // Deduplicate notifications
      if (_seenNotificationIds.contains(notification.id)) {
        // dev.log('NotificationsStream: Duplicate notification ${notification.id}, ignoring');
        return;
      }

      _seenNotificationIds.add(notification.id);

      // Keep only last 100 IDs
      if (_seenNotificationIds.length > 200) {
        final removeCount = _seenNotificationIds.length - 100;
        // Sets iterate in insertion order usually, cleaning up old ones
        for (var i = 0; i < removeCount; i++) {
          _seenNotificationIds.remove(_seenNotificationIds.first);
        }
      }

      dev.log(
        'NotificationsStream: Received notification: ${notification.title}',
      );
      _controller?.add(notification);
    } catch (e) {
      dev.log('NotificationsStream: Error parsing notification event: $e');
      dev.log('Raw Payload: ${_dataBuffer.toString()}');
    } finally {
      _currentEventName = null;
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
