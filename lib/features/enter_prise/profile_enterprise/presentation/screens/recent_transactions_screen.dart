import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/recent_transactions/recent_transactions_cubit.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/recent_transactions/recent_transactions_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecentTransactionsScreen extends StatelessWidget {
  const RecentTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RecentTransactionsCubit>()..getRecentTransactions(),
      child: Scaffold(
        backgroundColor: AppColors.lightBGColor,
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'recentTransactions'.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pushNamed(Routes.withdraw),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            8.horizontalSpace,
                            Text(
                              'withdraw'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── List ────────────────────────────────────────────────────────
              Expanded(
                child:
                    BlocBuilder<
                      RecentTransactionsCubit,
                      RecentTransactionsState
                    >(
                      builder: (context, state) {
                        if (state is RecentTransactionsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is RecentTransactionsError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 52.sp,
                                  color: AppColors.redColor,
                                ),
                                12.verticalSpace,
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is RecentTransactionsLoaded) {
                          if (state.items.isEmpty) {
                            return _EmptyState();
                          }
                          return ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                            itemCount: state.items.length,
                            separatorBuilder: (_, __) => 10.verticalSpace,
                            itemBuilder: (_, i) =>
                                _TransactionTile(item: state.items[i]),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.sp,
            color: AppColors.lightGreyText,
          ),
          16.verticalSpace,
          Text(
            'noTransactionsFound'.tr(),
            style: TextStyle(fontSize: 15.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final AllTransactionItem item;
  const _TransactionTile({required this.item});

  // ── colours ────────────────────────────────────────────────────────────────

  Color get _accentColor {
    if (!item.isWithdraw) return AppColors.secondaryColor; // deposit → orange
    switch (item.status) {
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.redColor;
      default:
        return AppColors.primaryColor; // pending → purple
    }
  }

  IconData get _icon {
    if (!item.isWithdraw) return Icons.arrow_downward_rounded; // deposit
    return item.source == 'points'
        ? Icons.stars_outlined
        : Icons.arrow_upward_rounded;
  }

  // ── label ──────────────────────────────────────────────────────────────────

  String _title() {
    if (!item.isWithdraw) {
      return item.description?.isNotEmpty == true
          ? item.description!
          : 'deposit'.tr();
    }
    return item.source == 'points' ? 'Points Withdrawal' : 'Wallet Withdrawal';
  }

  String? _badge() {
    if (item.isWithdraw) return item.status?.toUpperCase();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Format date
    String date = item.createdAt;
    try {
      date = DateFormat(
        'dd MMM yyyy  hh:mm a',
      ).format(DateTime.parse(item.createdAt));
    } catch (_) {}

    final badge = _badge();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon bubble
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_icon, color: _accentColor, size: 20.sp),
          ),
          12.horizontalSpace,
          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightMainText,
                  ),
                ),
                4.verticalSpace,
                Text(
                  date,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          // amount + optional badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isWithdraw ? '-' : '+'}${item.amount} ${item.currency ?? 'KWD'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: item.isWithdraw
                      ? AppColors.primaryColor
                      : AppColors.green,
                ),
              ),
              if (badge != null) ...[
                4.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: _accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── tiny helpers ──────────────────────────────────────────────────────────────
extension on int {
  Widget get verticalSpace => SizedBox(height: toDouble());
  Widget get horizontalSpace => SizedBox(width: toDouble());
}
