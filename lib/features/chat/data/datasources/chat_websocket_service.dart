import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/app_config/prefs_keys.dart';
import '../../../../core/helpers/secure_local_storage.dart';
import '../model/chat_message_model.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  StreamController<ChatMessageModel>? _streamController;

  Stream<ChatMessageModel>? get messageStream => _streamController?.stream;

  Future<void> connect(String url) async {
    disconnect();
    final token = await SecureLocalStorage.read(PrefsKeys.token);

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Origin': 'https://admin.askcrews.com',
        },
      );
      log('Connected to WebSocket: $url');

      _streamController = StreamController<ChatMessageModel>.broadcast();

      _channel!.stream.listen(
        (event) {
          log('WebSocket event: $event');
          try {
            final json = jsonDecode(event);

            final message = ChatMessageModel.fromJson(json);
            _streamController?.add(message);
          } catch (e) {
            log('Error parsing WebSocket message: $e');
          }
        },
        onDone: () {
          log('WebSocket closed');
          _streamController?.close();
          _channel = null;
        },
        onError: (error) {
          log('WebSocket error: $error');
          _streamController?.addError(error);
        },
      );
    } catch (e) {
      log('Error connecting to WebSocket: $e');
      rethrow;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _streamController?.close();
    _streamController = null;
    log('Disconnected from WebSocket');
  }

  void sendMessage(String message) {
    if (_channel != null) {
      final payload = jsonEncode({'message': message});
      _channel!.sink.add(payload);
      log('Sent message: $payload');
    } else {
      log('WebSocket not connected');
    }
  }
}
