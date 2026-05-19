import 'package:equatable/equatable.dart';
import '../../../auth/login/data/model/response/user_model.dart';
import 'chat_message_model.dart';

class ChatRoomModel extends Equatable {
  final int id;
  final UserModel participant1;
  final UserModel participant2;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoomModel({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatRoomModel copyWith({
    int? id,
    UserModel? participant1,
    UserModel? participant2,
    ChatMessageModel? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      participant1: UserModel.fromJson(json['participant1']),
      participant2: UserModel.fromJson(json['participant2']),
      lastMessage: json['last_message'] != null
          ? ChatMessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1': participant1.toJson(),
      'participant2': participant2.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    participant1,
    participant2,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
  ];
}
