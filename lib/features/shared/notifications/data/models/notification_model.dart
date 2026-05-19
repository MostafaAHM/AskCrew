import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      notificationType: json['notification_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      isRead: json['is_read'] == true,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata']
          : const {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'is_read': isRead,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    notificationType,
    title,
    message,
    isRead,
    metadata,
    createdAt,
  ];

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      notificationType: notificationType,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      metadata: metadata,
      createdAt: createdAt,
    );
  }
}
