import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? type;
  final String? action;
  final int? contentId;
  final String? contentType;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type,
    this.action,
    this.contentId,
    this.contentType,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      type: json['type']?.toString(),
      action: json['action']?.toString(),
      contentId: json['content_id'] != null
          ? int.tryParse(json['content_id'].toString())
          : null,
      contentType: json['content_type']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      if (type != null) 'type': type,
      if (action != null) 'action': action,
      if (contentId != null) 'content_id': contentId,
      if (contentType != null) 'content_type': contentType,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    createdAt,
    type,
    action,
    contentId,
    contentType,
    metadata,
  ];
}
