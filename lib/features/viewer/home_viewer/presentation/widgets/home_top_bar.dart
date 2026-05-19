import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:aflam/features/shared/notifications/presentation/widgets/notification_bell_icon.dart';
import '../../../../../../core/app_config/app_icons.dart';
import '../../../../../../core/helpers/authorization_helper.dart';
import '../../../../../../core/helpers/extensions.dart';
import '../../../../../../core/helpers/user_helper.dart';
import '../../../../../../config/routes/routes.dart';
import '../../../../auth/login/data/model/response/user_model.dart';

class HomeTopBar extends StatelessWidget {
  final void Function()? backPressed;
  final bool showChat;
  final bool showProfileStatus;

  const HomeTopBar({
    super.key,
    this.backPressed,
    this.showChat = false,
    this.showProfileStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ===== Left Icon =====
        InkWell(
          onTap: () {
            AuthorizationHelper.checkLoggedIn(context, () {
              if (showChat) {
                context.pushNamed(Routes.chatRooms);
              } else {
                context.pushNamed(Routes.homeSearch);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: SvgImageWidget(
              image: showChat ? AppIcons.chat : AppIcons.search,
              width: 25.w,
              height: 25.h,
            ),
          ),
        ),

        // ===== Center Logo =====
        Expanded(
          child: Center(
            child: Image.asset(
              AppIcons.logoPNG,
              width: 65.w,
              height: 65.h,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const NotificationBellIcon(),
        if (showProfileStatus) ...[
          SizedBox(width: 8.w),
          ValueListenableBuilder<UserModel?>(
            valueListenable: UserHelper.userNotifier,
            builder: (context, user, _) {
              if (user == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  // Navigate to profile details or edit
                  // context.pushNamed(Routes.viewerProfileDetails, extra: user);
                  // The user requested indicator. Navigation is secondary but good.
                  // As per instructions, Viewer Profile is "Settings / Profile tab"
                  // But let's allow tapping to go to Edit Profile for quick access
                  context.pushNamed(Routes.editViewerProfile);
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade300),
                        image:
                            (user.profilePhoto != null &&
                                user.profilePhoto!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(user.profilePhoto!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (user.profilePhoto == null ||
                              user.profilePhoto!.isEmpty)
                          ? Icon(Icons.person, size: 20.sp, color: Colors.grey)
                          : null,
                    ),
                    if (user.profile?.isAvailable == true)
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
