import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final int id;
  final int roomId;
  final int senderId;
  final String message;
  final List<String>? files;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    this.files,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    int senderId = 0;
    if (json['sender'] is int) {
      senderId = json['sender'];
    } else if (json['sender'] is Map) {
      senderId = json['sender']['id'] is int ? json['sender']['id'] : 0;
    }

    List<String>? filesList;
    if (json['files'] != null) {
      if (json['files'] is List) {
        filesList = (json['files'] as List)
            .map((e) {
              // Handle different formats: string URL or object with file field
              if (e is String) {
                return e;
              } else if (e is Map) {
                // Try different possible field names
                if (e['file'] != null && e['file'] is String) {
                  return e['file'];
                } else if (e['url'] != null && e['url'] is String) {
                  return e['url'];
                } else if (e['path'] != null && e['path'] is String) {
                  return e['path'];
                } else if (e['file_path'] != null && e['file_path'] is String) {
                  return e['file_path'];
                } else {
                  // If it's a map but no known field, try to get the first value
                  final values = e.values.toList();
                  if (values.isNotEmpty && values.first is String) {
                    return values.first;
                  }
                }
              }
              return e.toString();
            })
            .cast<String>()
            .where((url) => url.isNotEmpty && url != 'null')
            .toList();
        // Remove duplicates
        filesList = filesList.toSet().toList();
      } else if (json['files'] is String) {
        filesList = [json['files']];
      }
    }

    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : 0,
      roomId: json['room'] is int ? json['room'] : 0,
      senderId: senderId,
      message: json['content'] is String
          ? json['content']
          : (json['message'] is String ? json['message'] : ''),
      files: filesList,
      isRead: json['is_read'] is bool ? json['is_read'] : false,
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': roomId,
      'sender': senderId,
      'message': message,
      'files': files,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    roomId,
    senderId,
    message,
    files,
    isRead,
    createdAt,
  ];
}
