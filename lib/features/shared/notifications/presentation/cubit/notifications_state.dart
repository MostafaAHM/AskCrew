import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isConnected;
  final bool isRefreshing;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.isConnected = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    isConnected,
    isRefreshing,
  ];

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isConnected,
    bool? isRefreshing,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isConnected: isConnected ?? this.isConnected,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
