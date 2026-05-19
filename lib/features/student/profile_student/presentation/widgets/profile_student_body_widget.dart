import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../auth/logout/presentation/cubit/logout_cubit.dart';
import '../../../../../features/viewer/menu_viewer/presentation/widget/verification_tile.dart';
import '../../../../../features/shared/payment/data/repository/watermark_payment_repository.dart';
import '../../../../../features/shared/payment/presentation/cubit/watermark_payment_cubit.dart';
import '../../../../enter_prise/profile_enterprise/presentation/cubit/user_stats_cubit.dart';
import '../../../../enter_prise/profile_enterprise/presentation/cubit/user_stats_state.dart';
import '../../../../enter_prise/profile_enterprise/presentation/widgets/user_stats_section.dart';

class ProfileStudentBodyWidget extends StatelessWidget {
  const ProfileStudentBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WatermarkPaymentCubit(getIt<WatermarkPaymentRepository>()),
      child: BlocConsumer<WatermarkPaymentCubit, WatermarkPaymentState>(
        listener: (context, state) async {
          if (state is WatermarkPaymentChargeCreated) {
            final result = await context.pushNamed(
              Routes.paymentWebView,
              extra: {'paymentUrl': state.transactionUrl},
            );
            if (result == true && context.mounted) {
              context.read<WatermarkPaymentCubit>().onCheckoutFinished();
            }
          }

          if (state is WatermarkPaymentFailure) {
            AppMessages.showError(context, state.message);
          }

          if (state is WatermarkPaymentVerified) {
            AppMessages.showSuccess(context, 'verifiedSuccessfully'.tr());
          }
        },
        builder: (context, state) {
          final isLoading =
              state is WatermarkPaymentLoading ||
              state is WatermarkPaymentVerifying;

          return SafeArea(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAF7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: BlocProvider(
                      create: (context) =>
                          getIt<UserStatsCubit>()..getMyStats(),
                      child: BlocBuilder<UserStatsCubit, UserStatsState>(
                        builder: (context, state) {
                          if (state is UserStatsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is UserStatsError) {
                            return Center(child: Text(state.message));
                          }
                          if (state is UserStatsLoaded) {
                            return UserStatsSection(stats: state.stats);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  ValueListenableBuilder(
                    valueListenable: UserHelper.userNotifier,
                    builder: (context, user, _) {
                      final isVerified = user?.waterMark ?? false;
                      return VerificationTile(
                        isVerified: isVerified,
                        isLoading: isLoading,
                        onTap: () {
                          context
                              .read<WatermarkPaymentCubit>()
                              .startWatermarkPayment();
                        },
                      );
                    },
                  ),
                  AnimatedSettingsTile(
                    index: 0,
                    iconPath: AppIcons.profile,
                    title: 'yourProfile',
                    onTap: () {
                      final currentUser = UserHelper.userNotifier.value;
                      if (currentUser != null) {
                        context.pushNamed(
                          Routes.userProfile,
                          extra: currentUser,
                        );
                      }
                    },
                  ),
                  AnimatedSettingsTile(
                    index: 1,
                    icon: Icons.local_offer_outlined,
                    title: AppStrings.promoCodes,
                    onTap: () => context.pushNamed(Routes.historyScreen),
                  ),
                  AnimatedSettingsTile(
                    index: 2,
                    iconPath: AppIcons.swapUser,
                    title: 'swapAccounts',
                    isHighlighted: true,
                    onTap: () => context.pushNamed(Routes.swapAccounts),
                  ),
                  AnimatedSettingsTile(
                    index: 3,
                    iconPath: AppIcons.support,
                    title: 'technicalSupport',
                    onTap: () => context.pushNamed(Routes.technicalSupport),
                  ),
                  AnimatedSettingsTile(
                    index: 4,
                    iconPath: AppIcons.changeLanguage,
                    title: 'changeLanguage',
                    onTap: () => context.pushNamed(Routes.changeLanguage),
                  ),
                  AnimatedSettingsTile(
                    index: 5,
                    iconPath: AppIcons.changePassword,
                    title: 'changePassword',
                    onTap: () => context.pushNamed(Routes.changePassword),
                  ),
                  AnimatedSettingsTile(
                    index: 6,
                    iconPath: AppIcons.star1,
                    title: 'reward',
                    textColor: AppColors.secondaryColor,
                    iconColor: AppColors.secondaryColor,
                    onTap: () => context.pushNamed(Routes.rewards),
                  ),
                  AnimatedSettingsTile(
                    index: 7,
                    iconPath: AppIcons.deleteAcc,
                    title: 'deleteAccount',
                    onTap: () => context.pushNamed(Routes.deleteAccount),
                  ),
                  AnimatedSettingsTile(
                    index: 8,
                    iconPath: AppIcons.logOut,
                    title: 'logout',
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: '',
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return Opacity(
        opacity: animation.value,
        child: Transform.scale(
          scale: curved.value,
          child: Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: const _LogoutDialogBody(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _LogoutDialogBody extends StatelessWidget {
  const _LogoutDialogBody();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutLoading) {
            AppMessages.showLoading(context);
          } else if (state is LogoutSuccess) {
            AppMessages.hideLoading(context);
            UserHelper.clear();
            getIt<DioService>().clearHeaders();
            if (context.mounted) {
              context.pop();
              context.goNamed(Routes.login);
            }
          } else if (state is LogoutFailure) {
            AppMessages.hideLoading(context);
            UserHelper.clear();
            getIt<DioService>().clearHeaders();
            if (context.mounted) {
              context.pop();
              context.goNamed(Routes.login);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is LogoutLoading;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgImageWidget(
                image: AppIcons.logOut1,
                width: 40.w,
                height: 40.h,
              ),
              20.verticalSpace,
              Text(
                "areYouSureLogout".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "cancel".tr(),
                      backgroundColor: const Color(0xffF2F2F7),
                      style: const TextStyle(color: Colors.black),
                      onTap: isLoading ? null : () => context.pop(),
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: CustomButton(
                      text: "logout".tr(),
                      onTap: isLoading
                          ? null
                          : () => context.read<LogoutCubit>().logout(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String title;
  final bool isHighlighted;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.iconPath,
    this.icon,
    required this.title,
    this.isHighlighted = false,
    this.textColor,
    this.iconColor,
    this.onTap,
  }) : assert(
         iconPath != null || icon != null,
         'Either iconPath or icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    const Color normalText = Color(0xff4b4b4b);
    const Color highlightColor = Color(0xAD50177A);
    const Color arrowColor = Color(0xffb3b3b3);

    final Color finalTextColor = isHighlighted
        ? Colors.white
        : (textColor ?? normalText);
    final Color finalIconColor = isHighlighted
        ? Colors.white
        : (iconColor ?? normalText);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isHighlighted ? highlightColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: icon != null
                    ? Icon(icon, size: 24.sp, color: finalIconColor)
                    : (iconPath!.endsWith('.png')
                          ? Image.asset(
                              iconPath!,
                              width: 24.sp,
                              height: 24.sp,
                              color: finalIconColor,
                            )
                          : SvgImageWidget(
                              image: iconPath!,
                              width: 24.sp,
                              height: 24.sp,
                              colorFilter: ColorFilter.mode(
                                finalIconColor,
                                BlendMode.srcIn,
                              ),
                            )),
              ),
              12.horizontalSpace,
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    title.tr(),
                    style: TextStyle(
                      fontSize: 19.sp,
                      color: finalTextColor,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isHighlighted ? Colors.white : arrowColor,
                size: 25.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedSettingsTile extends StatefulWidget {
  final String? iconPath;
  final IconData? icon;
  final String title;
  final bool isHighlighted;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final int index;

  const AnimatedSettingsTile({
    super.key,
    this.iconPath,
    this.icon,
    required this.title,
    this.isHighlighted = false,
    this.textColor,
    this.iconColor,
    this.onTap,
    required this.index,
  });

  @override
  State<AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<AnimatedSettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fade;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    scale = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: scale,
          child: _SettingsTile(
            iconPath: widget.iconPath,
            icon: widget.icon,
            title: widget.title,
            isHighlighted: widget.isHighlighted,
            textColor: widget.textColor,
            iconColor: widget.iconColor,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
