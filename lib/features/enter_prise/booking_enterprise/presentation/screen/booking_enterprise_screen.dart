import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/animations/animated_slide_in.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_top_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widget/booking_card_exact.dart';
import '../widget/filtering_widget.dart';

class BookingEnterpriseScreen extends StatefulWidget {
  const BookingEnterpriseScreen({super.key});

  @override
  State<BookingEnterpriseScreen> createState() =>
      _BookingEnterpriseScreenState();
}

class _BookingEnterpriseScreenState extends State<BookingEnterpriseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMineSelected = true;
  List<String> _selectedTypes = [];

  Color get _orange => const Color(0xFFFF7A3C);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<BookingCubit>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.getBookingItems(
            refresh: true,
            mine: _isMineSelected,
            suggested: !_isMineSelected,
            types: _selectedTypes,
          );
        });
        return cubit;
      },
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: REdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      HomeTopBar(showChat: true),
                      8.height,
                      FilteringWidget(
                        onTabChanged: (isMine) {
                          setState(() {
                            _isMineSelected = isMine;
                          });
                          context.read<BookingCubit>().getBookingItems(
                            refresh: true,
                            mine: isMine,
                            suggested: !isMine,
                            types: _selectedTypes,
                          );
                        },
                        onFilterChanged: (mine, suggested, types) {
                          setState(() {
                            _selectedTypes = types;
                          });
                          context.read<BookingCubit>().getBookingItems(
                            refresh: true,
                            mine: mine,
                            suggested: suggested,
                            types: types,
                          );
                        },
                      ),
                      10.height,
                      Expanded(
                        child: BlocBuilder<BookingCubit, BookingState>(
                          builder: (context, state) {
                            if (state is BookingLoading) {
                              return ListView.separated(
                                itemCount: 5,
                                physics: const BouncingScrollPhysics(),
                                separatorBuilder: (_, __) => 12.height,
                                itemBuilder: (context, index) {
                                  return CustomShimmerWidget(
                                    width: double.infinity,
                                    height: 86.h,
                                    borderRadius: BorderRadius.circular(16.r),
                                  );
                                },
                              );
                            }

                            if (state is BookingError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(state.message),
                                    16.height,
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<BookingCubit>()
                                            .getBookingItems(
                                              refresh: true,
                                              mine: _isMineSelected,
                                              suggested: !_isMineSelected,
                                              types: _selectedTypes,
                                            );
                                      },
                                      child: Text(AppStrings.retry.tr()),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (state is BookingListLoaded) {
                              if (state.items.isEmpty) {
                                return Center(
                                  child: Text(AppStrings.noBookingItems.tr()),
                                );
                              }

                              return ListView.separated(
                                itemCount: state.items.length,
                                physics: const BouncingScrollPhysics(),
                                separatorBuilder: (_, __) => 12.height,
                                itemBuilder: (context, index) {
                                  return BookingCardExact(
                                    item: state.items[index],
                                    onEdit: () async {
                                      final result = await context.pushNamed(
                                        Routes.addBooking,
                                        extra: state.items[index],
                                      );
                                      if (result == true && context.mounted) {
                                        context
                                            .read<BookingCubit>()
                                            .getBookingItems(
                                              refresh: true,
                                              mine: _isMineSelected,
                                              suggested: !_isMineSelected,
                                              types: _selectedTypes,
                                            );
                                      }
                                    },
                                    onDelete: () {
                                      context
                                          .read<BookingCubit>()
                                          .deleteBookingItem(
                                            state.items[index].id,
                                          );
                                    },
                                  );
                                },
                              );
                            }

                            if (state is BookingDeleteSuccess) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.read<BookingCubit>().getBookingItems(
                                  refresh: true,
                                  mine: _isMineSelected,
                                  suggested: !_isMineSelected,
                                  types: _selectedTypes,
                                );
                              });
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFloatingButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserHelper.userNotifier,
      builder: (context, user, _) {
        final borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        );

        return Positioned(
          right: 12.w,
          bottom: 25.h,
          child: AnimatedSlideIn(
            index: 3,
            controller: _animationController,
            child: Material(
              color: _orange,
              elevation: 5,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: () async {
                  final result = await context.pushNamed(Routes.addBooking);
                  if (result == true && context.mounted) {
                    context.read<BookingCubit>().getBookingItems(
                      refresh: true,
                      mine: _isMineSelected,
                      suggested: !_isMineSelected,
                      types: _selectedTypes,
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    AppStrings.addBooking.tr(),
                    style: FontStyles.headline16.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
