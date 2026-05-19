import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_state.dart';
import 'package:aflam/features/shared/payment/data/model/server/wallet_add_options.dart';
import 'package:aflam/features/shared/payment/presentation/cubit/payment_cubit.dart';
import 'package:aflam/features/shared/payment/presentation/screens/payment_webview_screen.dart';
import 'package:aflam/features/shared/withdraw/data/model/collect_request_model.dart';
import 'package:aflam/features/shared/withdraw/presentation/cubit/withdraw_cubit.dart';
import 'package:aflam/features/shared/withdraw/presentation/cubit/withdraw_state.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<WithdrawCubit>()..loadHistory()),
        BlocProvider(create: (_) => getIt<PaymentCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..getMyProfile()),
      ],
      child: const _WalletBody(),
    );
  }
}

class _WalletBody extends StatefulWidget {
  const _WalletBody();

  @override
  State<_WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<_WalletBody> {
  final _depositAmountCtrl = TextEditingController();
  final _withdrawAmountCtrl = TextEditingController();

  @override
  void dispose() {
    _depositAmountCtrl.dispose();
    _withdrawAmountCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    if (error) {
      AppMessages.showError(context, msg);
    } else {
      AppMessages.showSuccess(context, msg);
    }
  }

  void _doDeposit(BuildContext ctx) {
    final v = double.tryParse(_depositAmountCtrl.text.trim());
    if (v == null || v <= 0) {
      _snack('pleaseEnterValidAmount'.tr(), error: true);
      return;
    }
    ctx.read<PaymentCubit>().walletAdd(WalletAddOptions(amount: v));
  }

  void _doWithdraw(BuildContext ctx) {
    final v = int.tryParse(_withdrawAmountCtrl.text.trim());
    if (v == null || v <= 0) {
      _snack('pleaseEnterValidAmount'.tr(), error: true);
      return;
    }
    ctx.read<WithdrawCubit>().submitWithdraw(amount: v, source: 'wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBGColor,
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: MultiBlocListener(
        listeners: [
          // ── Deposit result ──────────────────────────────────────────────────
          BlocListener<PaymentCubit, PaymentState>(
            listener: (ctx, state) async {
              if (state is PaymentLoading) return;
              if (state is PaymentContentSuccess) {
                final url = state.response.checkoutUrl;
                if (url != null && url.isNotEmpty) {
                  bool? result;
                  await Navigator.of(ctx, rootNavigator: true).push(
                    MaterialPageRoute<bool>(
                      fullscreenDialog: true,
                      builder: (_) => PaymentWebViewScreen(
                        paymentUrl: url,
                        onPaymentSuccess: () {
                          result = true;
                          Navigator.of(ctx, rootNavigator: true).pop(true);
                        },
                        onPaymentCancel: () {
                          result = false;
                          Navigator.of(ctx, rootNavigator: true).pop(false);
                        },
                      ),
                    ),
                  );
                  if (!ctx.mounted) return;
                  if (result == true) {
                    _snack('depositSuccess'.tr());
                    ctx.read<ProfileCubit>().getMyProfile();
                    _depositAmountCtrl.clear();
                  } else if (result == false) {
                    _snack('paymentCancelled'.tr(), error: true);
                  }
                }
              } else if (state is PaymentFailure) {
                _snack(state.message, error: true);
              }
            },
          ),
          // ── Withdraw result ─────────────────────────────────────────────────
          BlocListener<WithdrawCubit, WithdrawState>(
            listener: (ctx, state) {
              if (state is WithdrawSuccess) {
                _snack('withdrawSuccess'.tr());
                _withdrawAmountCtrl.clear();
                ctx.read<WithdrawCubit>().loadHistory();
              } else if (state is WithdrawError) {
                _snack(state.message, error: true);
              }
            },
          ),
          // ── Profile refresh ─────────────────────────────────────────────────
          BlocListener<ProfileCubit, ProfileState>(
            listener: (ctx, state) {
              if (state is ProfileLoaded) UserHelper.setUser(state.user);
            },
          ),
        ],
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: UserHelper.userNotifier,
          builder: (_, user, __) {
            final wallet = user?.wallet ?? '0.00';
            final points = user?.points ?? 0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ① Balance card
                  _BalanceCard(wallet: wallet, points: points),
                  24.verticalSpace,

                  // ② Deposit section
                  _SectionLabel(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'deposit'.tr(),
                    color: AppColors.secondaryColor,
                  ),
                  12.verticalSpace,
                  _AmountInput(
                    controller: _depositAmountCtrl,
                    hint: '0.00',
                    decimal: true,
                    accentColor: AppColors.secondaryColor,
                  ),
                  14.verticalSpace,
                  BlocBuilder<PaymentCubit, PaymentState>(
                    builder: (ctx, state) => _GradientButton(
                      label: 'deposit'.tr(),
                      icon: Icons.arrow_downward_rounded,
                      loading: state is PaymentLoading,
                      onTap: () => _doDeposit(ctx),
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  24.verticalSpace,

                  // divider
                  _Divider(),
                  24.verticalSpace,

                  // ③ Withdraw section
                  _SectionLabel(
                    icon: Icons.arrow_upward_rounded,
                    label: 'newWithdraw'.tr(),
                    color: AppColors.primaryColor,
                  ),
                  12.verticalSpace,
                  _AmountInput(
                    controller: _withdrawAmountCtrl,
                    hint: '0',
                    decimal: false,
                    accentColor: AppColors.primaryColor,
                  ),
                  14.verticalSpace,
                  BlocBuilder<WithdrawCubit, WithdrawState>(
                    builder: (ctx, state) => _GradientButton(
                      label: 'confirm'.tr(),
                      icon: Icons.send_rounded,
                      loading: state is WithdrawLoading,
                      onTap: () => _doWithdraw(ctx),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  24.verticalSpace,

                  // divider
                  _Divider(),
                  24.verticalSpace,

                  // ④ Withdraw history
                  _SectionLabel(
                    icon: Icons.history_rounded,
                    label: 'withdrawHistory'.tr(),
                    color: AppColors.greyText,
                  ),
                  16.verticalSpace,
                  BlocBuilder<WithdrawCubit, WithdrawState>(
                    buildWhen: (_, s) =>
                        s is WithdrawHistoryLoading ||
                        s is WithdrawHistoryLoaded ||
                        s is WithdrawHistoryError,
                    builder: (_, state) {
                      if (state is WithdrawHistoryLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (state is WithdrawHistoryError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is WithdrawHistoryLoaded) {
                        if (state.requests.isEmpty) {
                          return _EmptyHistory();
                        }
                        return Column(
                          children: state.requests
                              .map((r) => _RequestTile(request: r))
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final String wallet;
  final int points;
  const _BalanceCard({required this.wallet, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _Tile(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet'.tr(),
        value: wallet,
        unit: 'KWD',
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 22.sp),
        6.verticalSpace,
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        4.verticalSpace,
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: '  $unit',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        10.horizontalSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.lightMainText,
          ),
        ),
      ],
    );
  }
}

// ─── Amount Input ─────────────────────────────────────────────────────────────

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool decimal;
  final Color accentColor;
  const _AmountInput({
    required this.controller,
    required this.hint,
    required this.decimal,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            decimal ? RegExp(r'[\d.]') : RegExp(r'\d'),
          ),
        ],
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.lightMainText,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.hintColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'KWD',
              style: TextStyle(
                color: accentColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          suffixText: 'KWD',
          suffixStyle: TextStyle(
            fontSize: 13.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;
  final LinearGradient gradient;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: loading ? null : gradient,
            color: loading ? AppColors.borderColor : null,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 18.sp),
                      8.horizontalSpace,
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dividerColor,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
      ],
    );
  }
}

// ─── Empty History ────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 52.sp,
              color: AppColors.lightGreyText,
            ),
            12.verticalSpace,
            Text(
              'noWithdrawRequests'.tr(),
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Request Tile ─────────────────────────────────────────────────────────────

class _RequestTile extends StatelessWidget {
  final CollectRequestModel request;
  const _RequestTile({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.redColor;
      default:
        return AppColors.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = request.createdAt;
    try {
      date = DateFormat(
        'dd MMM yyyy  hh:mm a',
      ).format(DateTime.parse(request.createdAt));
    } catch (_) {}

    final isWallet = request.source == 'wallet';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          // icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isWallet
                  ? Icons.account_balance_wallet_outlined
                  : Icons.stars_outlined,
              color: _statusColor,
              size: 20.sp,
            ),
          ),
          12.horizontalSpace,
          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWallet ? 'Wallet Withdrawal' : 'Points Withdrawal',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightMainText,
                  ),
                ),
                3.verticalSpace,
                Text(
                  date,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          // amount + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${request.amount} KWD',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightMainText,
                ),
              ),
              4.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
