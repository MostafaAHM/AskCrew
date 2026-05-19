part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, success, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatRoomModel> chatRooms;
  final ChatRoomModel? selectedRoom;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chatRooms = const [],
    this.selectedRoom,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatRoomModel>? chatRooms,
    ChatRoomModel? selectedRoom,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chatRooms,
    selectedRoom,
    messages,
    errorMessage,
  ];
}
