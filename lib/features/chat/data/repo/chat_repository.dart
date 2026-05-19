import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/repository/repository.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';

abstract class ChatRepository extends Repository {
  Future<Either<CustomException, List<ChatRoomModel>>> getChatRooms();
  Future<Either<CustomException, ChatRoomModel>> getOrCreateChatRoom({
    required int userId,
  });
  Future<Either<CustomException, List<ChatMessageModel>>> getChatMessages({
    required int roomId,
  });

  Future<void> connectToChat(int roomId);
  void disconnectFromChat();
  void sendMessage(String message);
  Future<Either<CustomException, ChatMessageModel>> sendMessageWithFiles({
    required int roomId,
    required String content,
    required List<String> filePaths,
  });
  Stream<ChatMessageModel>? get messageStream;
}
