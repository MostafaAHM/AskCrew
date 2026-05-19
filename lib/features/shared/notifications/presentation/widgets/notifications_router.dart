import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/config/routes/routes.dart';
import '../../data/models/notification_model.dart';

class NotificationsRouter {
  static void onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    if (notification.notificationType == 'message' &&
        notification.metadata.containsKey('chat_room_id')) {
      final roomId = notification.metadata['chat_room_id'].toString();
      context.pushNamed(
        Routes.chatMessages,
        pathParameters: {'roomId': roomId},
      );
      return;
    }

    if (notification.metadata.containsKey('booking_id')) {}
  }
}
