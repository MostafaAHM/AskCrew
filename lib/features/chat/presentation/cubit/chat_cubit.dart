import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/user_helper.dart';
import '../../data/model/chat_message_model.dart';
import '../../data/model/chat_room_model.dart';
import '../../data/repo/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(const ChatState());

  Future<void> getChatRooms() async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _repository.getChatRooms();
    result.fold(
      (error) => emit(
        state.copyWith(status: ChatStatus.error, errorMessage: error.message),
      ),
      (rooms) {
        final sortedRooms = List<ChatRoomModel>.from(rooms);
        sortedRooms.sort((a, b) {
          if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
          if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        emit(
          state.copyWith(status: ChatStatus.success, chatRooms: sortedRooms),
        );
      },
    );
  }

  Future<void> getOrCreateChatRoom(int userId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _repository.getOrCreateChatRoom(userId: userId);
    result.fold(
      (error) => emit(
        state.copyWith(status: ChatStatus.error, errorMessage: error.message),
      ),
      (room) {
        emit(state.copyWith(status: ChatStatus.success, selectedRoom: room));
        getChatMessages(room.id);
        connectToChat(room.id);
      },
    );
  }

  Future<void> getChatMessages(int roomId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _repository.getChatMessages(roomId: roomId);
    result.fold(
      (error) => emit(
        state.copyWith(status: ChatStatus.error, errorMessage: error.message),
      ),
      (messages) =>
          emit(state.copyWith(status: ChatStatus.success, messages: messages)),
    );
  }

  Future<void> connectToChat(int roomId) async {
    await _repository.connectToChat(roomId);
    _repository.messageStream?.listen((message) {
      final currentMessages = List<ChatMessageModel>.from(state.messages);

      // Check if message already exists (to prevent duplicates)
      final messageExists = currentMessages.any((m) => m.id == message.id);
      if (!messageExists) {
        currentMessages.add(message);
      }

      final currentUserId = UserHelper.userNotifier.value?.id;
      final isCurrentUserMessage =
          currentUserId != null && message.senderId == currentUserId;

      final isCurrentRoom = state.selectedRoom?.id == roomId;

      final updatedRooms = state.chatRooms.map((room) {
        if (room.id == roomId) {
          final shouldIncrementUnread = !isCurrentUserMessage && !isCurrentRoom;

          return room.copyWith(
            lastMessage: message,
            updatedAt: message.createdAt,
            unreadCount: shouldIncrementUnread
                ? room.unreadCount + 1
                : room.unreadCount,
          );
        }
        return room;
      }).toList();

      updatedRooms.sort((a, b) {
        if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
        if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

      emit(state.copyWith(messages: currentMessages, chatRooms: updatedRooms));
    });
  }

  void sendMessage(String message) {
    _repository.sendMessage(message);
  }

  Future<void> sendMessageWithFiles({
    required int roomId,
    required String content,
    required List<String> filePaths,
  }) async {
    final result = await _repository.sendMessageWithFiles(
      roomId: roomId,
      content: content,
      filePaths: filePaths,
    );

    result.fold(
      (error) {
        // Handle error - could emit error state if needed
      },
      (message) {
        // Add the sent message to the messages list only if it doesn't exist
        // (WebSocket will also send it, so we check to avoid duplicates)
        final currentMessages = List<ChatMessageModel>.from(state.messages);
        final messageExists = currentMessages.any((m) => m.id == message.id);
        if (!messageExists) {
          currentMessages.add(message);
          emit(state.copyWith(messages: currentMessages));
        }
      },
    );
  }

  void disconnectChat() {
    _repository.disconnectFromChat();
  }

  void markRoomAsRead(int roomId) {
    final updatedRooms = state.chatRooms.map((room) {
      if (room.id == roomId) {
        return room.copyWith(unreadCount: 0);
      }
      return room;
    }).toList();

    updatedRooms.sort((a, b) {
      if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
      if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    emit(state.copyWith(chatRooms: updatedRooms));
  }

  @override
  Future<void> close() {
    _repository.disconnectFromChat();
    return super.close();
  }
}
