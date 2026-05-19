import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/app_config/app_urls.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_request.dart';
import '../datasources/chat_websocket_service.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl extends ChatRepository {
  final ChatWebSocketService _webSocketService = ChatWebSocketService();

  @override
  Future<Either<CustomException, List<ChatRoomModel>>> getChatRooms() async {
    return await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.chatRooms,
          method: RequestMethod.get,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          final list = json as List<dynamic>;
          return list
              .map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    });
  }

  @override
  Future<Either<CustomException, ChatRoomModel>> getOrCreateChatRoom({
    required int userId,
  }) async {
    return await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.getOrCreateChatRoom,
          method: RequestMethod.post,
          requestWithOutToken: false,
          isFormData: true,
          formDataBody: FormData.fromMap({'user_id': userId}),
        ),
        mapper: (json) => ChatRoomModel.fromJson(json),
      );
    });
  }

  @override
  Future<Either<CustomException, List<ChatMessageModel>>> getChatMessages({
    required int roomId,
  }) async {
    return await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.chatMessages(roomId),
          method: RequestMethod.get,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          final list = json as List<dynamic>;
          return list
              .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    });
  }

  @override
  Future<void> connectToChat(int roomId) async {
    await _webSocketService.connect(AppUrls.chatWebSocket(roomId));
  }

  @override
  void disconnectFromChat() {
    _webSocketService.disconnect();
  }

  @override
  void sendMessage(String message) {
    _webSocketService.sendMessage(message);
  }

  @override
  Future<Either<CustomException, ChatMessageModel>> sendMessageWithFiles({
    required int roomId,
    required String content,
    required List<String> filePaths,
  }) async {
    return await exceptionHandler(() async {
      final formDataMap = <String, dynamic>{'content': content};

      final files = <MultipartFile>[];
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          final fileName = file.path.split('/').last;
          final multipartFile = await MultipartFile.fromFile(
            filePath,
            filename: fileName,
          );
          files.add(multipartFile);
        }
      }

      if (files.isNotEmpty) {
        formDataMap['files'] = files;
      }

      final formData = FormData.fromMap(formDataMap);

      return await dioService.callApi(
        NetworkRequest(
          AppUrls.sendChatMessage(roomId),
          method: RequestMethod.post,
          requestWithOutToken: false,
          isFormData: true,
          formDataBody: formData,
        ),
        mapper: (json) => ChatMessageModel.fromJson(json),
      );
    });
  }

  @override
  Stream<ChatMessageModel>? get messageStream =>
      _webSocketService.messageStream;
}
