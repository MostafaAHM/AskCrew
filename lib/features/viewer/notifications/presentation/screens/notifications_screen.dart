import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/features/shared/notifications/data/models/notification_model.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_state.dart';
import 'package:aflam/features/shared/notifications/presentation/widgets/notifications_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationsCubit>();
    cubit.refreshFromApi();
    cubit.startStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.notifications.tr(),
        showLogoInBackAppBar: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => _showMarkAllReadConfirmDialog(context),
                  child: Text(
                    AppStrings.markAllAsRead.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading && state is! NotificationsLoaded) {
            return _buildShimmerList();
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.notificationErrorMessage.tr(),
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsCubit>().refreshFromApi();
                    },
                    child: Text(
                      'Retry'.tr(),
                    ), // Assuming 'Retry' or generic key
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.noNotifications.tr(),
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<NotificationsCubit>().refreshFromApi();
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1.h, thickness: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  // Animated Item
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(
                      milliseconds: 400 + (index * 50).clamp(0, 500),
                    ),
                    curve: Curves.easeOutQuad,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: NotificationItem(
                      notification: notification,
                      onTap: () {
                        context.read<NotificationsCubit>().markAsRead(
                          notification.id,
                        );
                        NotificationsRouter.onNotificationTap(
                          context,
                          notification,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showMarkAllReadConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.markAllAsRead.tr()),
        content: Text(
          'confirm_mark_all_read'.tr(),
        ), // Using a key or assuming existence
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
              Navigator.pop(context);
            },
            child: Text(AppStrings.confirm.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 12.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: isRead
            ? Colors.transparent
            : Theme.of(context).primaryColor.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            Padding(
              padding: EdgeInsets.only(top: 18.h, right: 8.w),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRead
                      ? Colors.transparent
                      : Theme.of(context).primaryColor,
                ),
              ),
            ),
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getNotificationIcon(
                  notification.notificationType,
                ), // Use correct property
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification
                        .message, // Shared model uses 'message', not 'body'
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isRead ? Colors.grey[600] : Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'message':
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'booking':
        return Icons.event_available;
      case 'payment':
        return Icons.payment;
      case 'content':
      case 'movie':
      case 'series':
        return Icons.movie_creation_outlined;
      case 'reward':
        return Icons.card_giftcard;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications_none;
    }
  }
}
