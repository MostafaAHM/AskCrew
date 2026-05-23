import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/app_config/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/model/chat_message_model.dart';
import '../../data/model/chat_room_model.dart';
import '../cubit/chat_cubit.dart';
import 'chat_screen.dart';

String? _convertToString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()..getChatRooms(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),

        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              return _buildShimmerLoading();
            } else if (state.status == ChatStatus.error) {
              return _buildErrorState(context, state.errorMessage);
            } else if (state.chatRooms.isEmpty) {
              return _buildEmptyState();
            }

            final sortedRooms = List<ChatRoomModel>.from(state.chatRooms);
            sortedRooms.sort((a, b) {
              if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
              if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
              return b.updatedAt.compareTo(a.updatedAt);
            });

            final unreadChats = sortedRooms
                .where((room) => room.unreadCount > 0)
                .toList();
            final readChats = sortedRooms
                .where((room) => room.unreadCount == 0)
                .toList();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      AppStrings.chatWithOwner.tr(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (unreadChats.isNotEmpty) ...[
                    Text(
                      AppStrings.unreadMessages.tr(),
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    16.verticalSpace,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: unreadChats.length,
                      separatorBuilder: (context, index) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return _ChatRoomTile(
                          room: unreadChats[index],
                          index: index,
                        );
                      },
                    ),
                    24.verticalSpace,
                  ],
                  if (readChats.isNotEmpty) ...[
                    Text(
                      AppStrings.readMessages.tr(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    16.verticalSpace,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: readChats.length,
                      separatorBuilder: (context, index) => 16.verticalSpace,
                      itemBuilder: (context, index) {
                        return _ChatRoomTile(
                          room: readChats[index],
                          index: index,
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: 6,
      separatorBuilder: (context, index) => 16.verticalSpace,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: 150.w,
                    color: Colors.grey[300],
                  ),
                  8.verticalSpace,
                  Container(
                    height: 12.h,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: AppColors.errorColor),
          16.verticalSpace,
          Text(
            errorMessage ?? AppStrings.errorLoadingChats.tr(),
            style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64.r, color: Colors.grey[400]),
          16.verticalSpace,
          Text(
            AppStrings.noChatsYet.tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 18.sp),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final int index;

  const _ChatRoomTile({required this.room, required this.index});

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;

    // Get the other user - participants are now required (non-nullable)
    final otherUser =
        currentUser != null && room.participant1.id == currentUser.id
        ? room.participant2
        : room.participant1;

    return InkWell(
      onTap: () async {
        final chatCubit = context.read<ChatCubit>();
        chatCubit.markRoomAsRead(room.id);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatCubit,
              child: ChatScreen(
                roomId: room.id,
                roomName: otherUser.fullname,
                otherUserImage: otherUser.profilePhoto,
                specification: _convertToString(
                  otherUser.profile?.specification,
                ),
                otherUser: otherUser,
              ),
            ),
          ),
        );
        chatCubit.getChatRooms();
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pushNamed(Routes.userProfile, extra: otherUser);
            },
            child: CircleAvatar(
              radius: 28.r,
              backgroundImage: otherUser.profilePhoto != null
                  ? NetworkImage(otherUser.profilePhoto!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: otherUser.profilePhoto == null
                  ? Text(
                      otherUser.fullname.isNotEmpty
                          ? otherUser.fullname[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherUser.fullname.isNotEmpty
                            ? otherUser.fullname
                            : 'Unknown User',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (room.unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          room.unreadCount > 99
                              ? '99+'
                              : room.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                4.verticalSpace,
                _buildLastMessagePreview(
                  room.lastMessage,
                  room.unreadCount > 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastMessagePreview(
    ChatMessageModel? chatMessageModel,
    bool isUnread,
  ) {
    if (chatMessageModel == null) {
      return Text(
        AppStrings.noMessagesYet.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final hasText = chatMessageModel.message.isNotEmpty;
    final hasFiles =
        chatMessageModel.files != null && chatMessageModel.files!.isNotEmpty;

    if (!hasText && !hasFiles) {
      return Text(
        AppStrings.noMessagesYet.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Row(
      children: [
        if (hasFiles) ...[
          _buildFileIcon(chatMessageModel.files!.first, isUnread),
          4.horizontalSpace,
        ],
        Expanded(
          child: Text(
            hasText
                ? chatMessageModel.message
                : _getFilePreviewText(chatMessageModel.files!.first),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnread ? const Color(0xFF333333) : Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileIcon(String fileUrl, bool isUnread) {
    final cleanUrl = fileUrl.trim();
    final isImage =
        cleanUrl.toLowerCase().endsWith('.jpg') ||
        cleanUrl.toLowerCase().endsWith('.jpeg') ||
        cleanUrl.toLowerCase().endsWith('.png') ||
        cleanUrl.toLowerCase().endsWith('.gif') ||
        cleanUrl.toLowerCase().endsWith('.webp') ||
        cleanUrl.toLowerCase().contains('/images/') ||
        cleanUrl.toLowerCase().contains('image');

    return Icon(
      isImage ? Icons.image : Icons.insert_drive_file,
      size: 16.r,
      color: isUnread ? const Color(0xFF333333) : Colors.grey[600],
    );
  }

  String _getFilePreviewText(String fileUrl) {
    final cleanUrl = fileUrl.trim();
    final isImage =
        cleanUrl.toLowerCase().endsWith('.jpg') ||
        cleanUrl.toLowerCase().endsWith('.jpeg') ||
        cleanUrl.toLowerCase().endsWith('.png') ||
        cleanUrl.toLowerCase().endsWith('.gif') ||
        cleanUrl.toLowerCase().endsWith('.webp') ||
        cleanUrl.toLowerCase().contains('/images/') ||
        cleanUrl.toLowerCase().contains('image');

    if (isImage) {
      return AppStrings.photo.tr();
    } else {
      final fileName = cleanUrl.split('/').last;
      if (fileName.length > 20) {
        return '${fileName.substring(0, 20)}...';
      }
      return fileName;
    }
  }
}
