import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/routes/routes.dart';
import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_urls.dart';
import '../../../../core/app_config/prefs_keys.dart';
import '../../../../core/helpers/secure_local_storage.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../features/auth/login/data/model/response/user_model.dart';
import '../../data/model/chat_message_model.dart';
import '../cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String? otherUserImage;
  final UserModel? otherUser;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    this.otherUserImage,
    this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int? _currentUserId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    final chatCubit = context.read<ChatCubit>();
    chatCubit.getChatMessages(widget.roomId);
    chatCubit.connectToChat(widget.roomId);
    chatCubit.markRoomAsRead(widget.roomId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<ChatCubit>().disconnectChat();
    super.deactivate();
  }

  Future<void> _loadCurrentUser() async {
    final userJson = await SecureLocalStorage.read(PrefsKeys.user);
    if (userJson != null) {
      final user = UserModel.fromJson(jsonDecode(userJson));
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: Column(
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
          _buildUserProfileHeader(),
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.messages.isNotEmpty) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state.status == ChatStatus.loading &&
                    state.messages.isEmpty) {
                  return _buildShimmerLoading();
                }

                if (state.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  reverse: true,
                  itemCount: state.messages.length,
                  separatorBuilder: (context, index) => 16.verticalSpace,
                  itemBuilder: (context, index) {
                    final message =
                        state.messages[state.messages.length - 1 - index];
                    final isMe =
                        _currentUserId != null &&
                        message.senderId == _currentUserId;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
          _ChatInputArea(roomId: widget.roomId),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.otherUser != null) {
                context.pushNamed(Routes.userProfile, extra: widget.otherUser);
              }
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.otherUserImage != null
                      ? NetworkImage(widget.otherUserImage!)
                      : null,
                  child: widget.otherUserImage == null
                      ? Text(
                          widget.roomName.isNotEmpty
                              ? widget.roomName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roomName,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        itemCount: 8,
        separatorBuilder: (context, index) => 16.verticalSpace,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 200.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r).copyWith(
                  bottomRight: isMe ? Radius.zero : null,
                  bottomLeft: !isMe ? Radius.zero : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64.r, color: Colors.grey[300]),
          16.verticalSpace,
          Text(
            AppStrings.noMessagesYet.tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.index,
  });

  void _showImageFullScreen(
    BuildContext context,
    String imageUrl,
    List<String> allImages,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) =>
          _ImageFullScreenViewer(imageUrl: imageUrl, allImages: allImages),
    );
  }

  void _openFile(BuildContext context, String fileUrl, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.file.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: 64.r, color: Colors.grey[600]),
            16.verticalSpace,
            Text(
              fileName,
              style: TextStyle(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.close.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 280.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFFFFF0E6)
                : const Color(0xFFF3F0F7), // Light Orange / Light Purple
            borderRadius: BorderRadius.circular(16.r).copyWith(
              bottomRight: isMe ? Radius.zero : null,
              bottomLeft: !isMe ? Radius.zero : null,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.message.isNotEmpty)
                Text(
                  message.message,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              if (message.files != null && message.files!.isNotEmpty) ...[
                if (message.message.isNotEmpty) 8.verticalSpace,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: message.files!.map((fileUrl) {
                    // Clean the URL - remove any query parameters or extra paths
                    String cleanUrl = fileUrl.trim();
                    if (cleanUrl.contains('?')) {
                      cleanUrl = cleanUrl.split('?').first;
                    }

                    // Check if it's an image by extension or content type
                    final isImage =
                        cleanUrl.toLowerCase().endsWith('.jpg') ||
                        cleanUrl.toLowerCase().endsWith('.jpeg') ||
                        cleanUrl.toLowerCase().endsWith('.png') ||
                        cleanUrl.toLowerCase().endsWith('.gif') ||
                        cleanUrl.toLowerCase().endsWith('.webp') ||
                        cleanUrl.toLowerCase().contains('/images/') ||
                        cleanUrl.toLowerCase().contains('image');

                    final fullUrl = cleanUrl.startsWith('http')
                        ? cleanUrl
                        : AppUrls.imageLink(cleanUrl);

                    return isImage
                        ? GestureDetector(
                            onTap: () => _showImageFullScreen(
                              context,
                              fullUrl,
                              message.files!,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                fullUrl,
                                width: 150.w,
                                height: 150.h,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 150.w,
                                        height: 150.h,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 150.w,
                                      height: 150.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40.r,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _openFile(
                              context,
                              fullUrl,
                              fileUrl.split('/').last,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: 24.r,
                                    color: Colors.grey[700],
                                  ),
                                  8.horizontalSpace,
                                  Flexible(
                                    child: Text(
                                      fileUrl.split('/').last,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        8.verticalSpace,
        Text(
          DateFormat('hh:mm a').format(message.createdAt),
          style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _ImageFullScreenViewer extends StatefulWidget {
  final String imageUrl;
  final List<String> allImages;

  const _ImageFullScreenViewer({
    required this.imageUrl,
    required this.allImages,
  });

  @override
  State<_ImageFullScreenViewer> createState() => _ImageFullScreenViewerState();
}

class _ImageFullScreenViewerState extends State<_ImageFullScreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allImages.indexOf(widget.imageUrl);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.allImages.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.allImages.length}',
                style: TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allImages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.allImages[index];
          final fullUrl = imageUrl.startsWith('http')
              ? imageUrl
              : AppUrls.imageLink(imageUrl);

          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64.r,
                        color: Colors.white54,
                      ),
                      16.verticalSpace,
                      Text(
                        AppStrings.failedToLoadImage.tr(),
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatInputArea extends StatefulWidget {
  final int roomId;

  const _ChatInputArea({required this.roomId});

  @override
  State<_ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<_ChatInputArea> {
  final _controller = TextEditingController();
  bool _hasText = false;
  final List<String> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText =
            _controller.text.trim().isNotEmpty || _selectedFiles.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            result.files
                .where((file) => file.path != null)
                .map((file) => file.path!)
                .toList(),
          );
          _hasText =
              _controller.text.trim().isNotEmpty || _selectedFiles.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPickingFile.tr()}: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _hasText =
          _controller.text.trim().isNotEmpty || _selectedFiles.isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    if (_hasText) {
      final content = _controller.text.trim();

      if (_selectedFiles.isNotEmpty) {
        // Send message with files
        await context.read<ChatCubit>().sendMessageWithFiles(
          roomId: widget.roomId,
          content: content,
          filePaths: _selectedFiles,
        );
      } else {
        // Send text message only
        context.read<ChatCubit>().sendMessage(content);
      }

      _controller.clear();
      setState(() {
        _selectedFiles.clear();
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 10.h,
        bottom: 50.h,
      ),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFiles.isNotEmpty)
              Container(
                height: 80.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final filePath = _selectedFiles[index];
                    final file = File(filePath);
                    final fileName = file.path.split('/').last;
                    final isImage =
                        fileName.toLowerCase().endsWith('.jpg') ||
                        fileName.toLowerCase().endsWith('.jpeg') ||
                        fileName.toLowerCase().endsWith('.png') ||
                        fileName.toLowerCase().endsWith('.gif');

                    return Container(
                      margin: EdgeInsets.only(right: 8.w),
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        children: [
                          if (isImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                file,
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Center(
                              child: Icon(
                                Icons.insert_drive_file,
                                size: 32.r,
                                color: Colors.grey[600],
                              ),
                            ),
                          Positioned(
                            top: 4.h,
                            right: 4.w,
                            child: GestureDetector(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16.r,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 15.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.typeYourMessage.tr(),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: AppColors.secondaryColor,
                    size: 24.r,
                  ),
                  onPressed: _pickFiles,
                ),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: AppColors.secondaryColor,
                    size: 24.r,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
