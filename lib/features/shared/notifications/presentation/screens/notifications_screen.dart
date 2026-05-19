import 'dart:async';

import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:aflam/features/shared/notifications/data/models/notification_model.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_state.dart';
import 'package:aflam/features/shared/notifications/presentation/widgets/notification_item_card.dart';
import 'package:aflam/features/shared/notifications/presentation/widgets/notifications_router.dart';
import 'package:aflam/features/shared/notifications/presentation/widgets/premium_confirmation_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aflam/core/helpers/user_helper.dart';

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
      backgroundColor: Colors.white,
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.notifications.tr(),
        showLogoInBackAppBar: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return Center(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.w),
                    child: IconButton(
                      onPressed: () => _showMarkAllReadDialog(context),
                      icon: const Icon(Icons.done_all_rounded),
                      tooltip: AppStrings.markAllAsRead.tr(),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: UserHelper.userNotifier,
        builder: (context, user, _) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgImageWidget(
                    image: AppIcons.notifications,
                    width: 80.w,
                    height: 80.h,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  20.verticalSpace,
                  Text(
                    AppStrings.loginRequired.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          return BlocConsumer<NotificationsCubit, NotificationsState>(
            listener: (context, state) {
              if (state is NotificationsError) {
                AppMessages.showError(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is NotificationsLoading &&
                  state is! NotificationsLoaded) {
                return Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return NotificationItemCard(
                        notification: NotificationModel(
                          id: index,
                          notificationType: 'system',
                          title: 'Loading Notification Content',
                          message:
                              'This is a sample notification message that will be replaced by actual data.',
                          isRead: index % 2 == 0,
                          metadata: const {},
                          createdAt: DateTime.now(),
                        ),
                        onTap: () {},
                      );
                    },
                  ),
                );
              }

              if (state is NotificationsError) {
                return _buildErrorState(context, state.message);
              }

              if (state is NotificationsLoaded) {
                if (state.notifications.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<NotificationsCubit>().refreshFromApi();
                  },
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    itemCount: state.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return _AnimatedListItem(
                        key: ValueKey(notification.id),
                        index: index,
                        child: NotificationItemCard(
                          notification: notification,
                          isFirst: index == 0,
                          isLast: index == state.notifications.length - 1,
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: SvgImageWidget(
                image: AppIcons.notifications,
                width: 80.w,
                height: 80.w,
                colorFilter: ColorFilter.mode(
                  Colors.grey[300]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.noNotifications.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.noNotificationsDescription.tr(),
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64.sp,
            color: Colors.red[300],
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.notificationErrorTitle.tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<NotificationsCubit>().refreshFromApi(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: Text(
              AppStrings.retry.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAllReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PremiumConfirmationDialog(
        title: AppStrings.markAllAsRead.tr(),
        subtitle: AppStrings.confirmMarkAllRead.tr(),
        confirmText: AppStrings.confirm.tr(),
        cancelText: AppStrings.cancel.tr(),
        confirmColor: Theme.of(context).primaryColor,
        iconPath: AppIcons.notifications,
        onConfirm: () {
          context.read<NotificationsCubit>().markAllAsRead();
        },
      ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 600));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
