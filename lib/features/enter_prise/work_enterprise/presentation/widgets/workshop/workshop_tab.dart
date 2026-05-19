import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../screens/workshop/add_workshop_screen.dart';
import '../../../data/models/response/workshop_response_model.dart';
import '../../cubit/workshop/workshop_cubit.dart';
import '../../cubit/workshop/workshop_state.dart';
import 'work_shop_details.dart';
import 'workshop_card.dart';

class WorkshopTab extends StatefulWidget {
  final ValueChanged<bool>? onShowFloatingButtonChanged;

  const WorkshopTab({super.key, this.onShowFloatingButtonChanged});

  @override
  State<WorkshopTab> createState() => WorkshopTabState();
}

class WorkshopTabState extends State<WorkshopTab> {
  bool _showDetails = false;
  bool _showAddWorkshop = false;
  WorkshopResponseModel? _workshopToUpdate;
  int? _selectedWorkshopId;
  late WorkshopCubit _workshopCubit;
  bool _isMyWorkshops = true; // false = Suggested, true = my own

  WorkShopDetailsMode _mode = WorkShopDetailsMode.ownerManage;

  bool get showAddWorkshop => _showAddWorkshop;

  @override
  void initState() {
    super.initState();
    _workshopCubit = getIt<WorkshopCubit>();
    // Check if user is student - if so, show suggested workshops, otherwise show my own
    final currentUser = UserHelper.userNotifier.value;
    final isStudent = currentUser?.type.toLowerCase() == 'student';
    _isMyWorkshops =
        !isStudent; // Students see suggested, others see my own by default
    _workshopCubit.getWorkshops(refresh: true, isMyWorkshops: _isMyWorkshops);
  }

  void openAddWorkshop({WorkshopResponseModel? workshopToUpdate}) {
    setState(() {
      _showAddWorkshop = true;
      _workshopToUpdate = workshopToUpdate;
      widget.onShowFloatingButtonChanged?.call(false);
    });
  }

  void closeAddWorkshop() {
    if (!_showAddWorkshop) return;
    setState(() {
      _showAddWorkshop = false;
      _workshopToUpdate = null;
      widget.onShowFloatingButtonChanged?.call(true);
      // Refresh workshops list after closing add screen
      _workshopCubit.getWorkshops(refresh: true, isMyWorkshops: _isMyWorkshops);
    });
  }

  void reset() {
    if (_showAddWorkshop || _showDetails) {
      setState(() {
        _showAddWorkshop = false;
        _showDetails = false;
        _workshopToUpdate = null;
        _selectedWorkshopId = null;
        widget.onShowFloatingButtonChanged?.call(true);
      });
      // Optionally refresh if needed, or just let it be
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddWorkshop) {
      return BlocProvider.value(
        value: _workshopCubit,
        child: AddWorkshopScreen(
          workshopToUpdate: _workshopToUpdate,
          onBack: closeAddWorkshop,
        ),
      );
    }

    if (_showDetails && _selectedWorkshopId != null) {
      return BlocProvider.value(
        value: _workshopCubit,
        child: WorkShopDetails(
          workshopId: _selectedWorkshopId!,
          mode: _mode,
          onBack: () {
            setState(() {
              _showDetails = false;
              _selectedWorkshopId = null;
            });
            // Show floating button when closing details
            widget.onShowFloatingButtonChanged?.call(true);
          },
        ),
      );
    }

    return BlocProvider.value(
      value: _workshopCubit,
      child: BlocListener<WorkshopCubit, WorkshopState>(
        listenWhen: (previous, current) {
          return current is WorkshopSuccess ||
              current is WorkshopDeleteSuccess ||
              current is WorkshopApplySuccess ||
              current is WorkshopRegistrationActionSuccess ||
              current is WorkshopError;
        },
        listener: (context, state) {
          if (state is WorkshopSuccess) {
            _workshopCubit.getWorkshops(
              refresh: true,
              isMyWorkshops: _isMyWorkshops,
            );
            AppMessages.showSuccess(context, state.message);
          } else if (state is WorkshopDeleteSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppMessages.showSuccess(context, state.message);
            });
          } else if (state is WorkshopApplySuccess) {
            AppMessages.showSuccess(context, state.message);
          } else if (state is WorkshopRegistrationActionSuccess) {
            AppMessages.showSuccess(context, state.message);
          } else if (state is WorkshopError) {
            AppMessages.showError(context, state.message);
          }
        },
        child: BlocBuilder<WorkshopCubit, WorkshopState>(
          builder: (context, state) {
            // Check if user is student
            final currentUser = UserHelper.userNotifier.value;
            final isStudent = currentUser?.type.toLowerCase() == 'student';

            return Column(
              children: [
                // Filter buttons - only show if user is not a student
                if (!isStudent)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      top: 12.h,
                      bottom: 10.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton(
                            text: 'myOwn'.tr(),
                            isSelected: _isMyWorkshops,
                            onTap: () {
                              if (!_isMyWorkshops) {
                                setState(() {
                                  _isMyWorkshops = true;
                                });
                                // Get user's own workshops
                                _workshopCubit.getWorkshops(
                                  refresh: true,
                                  isMyWorkshops: true,
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildFilterButton(
                            text: 'suggested'.tr(),
                            isSelected: !_isMyWorkshops,
                            onTap: () {
                              if (_isMyWorkshops) {
                                setState(() {
                                  _isMyWorkshops = false;
                                });
                                // Get all workshops (will be filtered to show only non-owned ones)
                                _workshopCubit.getWorkshops(
                                  refresh: true,
                                  isMyWorkshops: false,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                // Workshops list
                Expanded(child: _buildWorkshopsList(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : const Color(0xFFD4A574),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFFD4A574),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopsList(WorkshopState state) {
    if (state is WorkshopLoading && state is! WorkshopListLoaded) {
      return Padding(
        padding: EdgeInsets.only(top: 0.h),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: 6,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 200.w / 120.h,
          ),
          itemBuilder: (context, index) {
            return CustomShimmerWidget(
              width: 159.w,
              height: 150.h,
              borderRadius: BorderRadius.circular(5.r),
            );
          },
        ),
      );
    }

    if (state is WorkshopError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ],
        ),
      );
    }

    final allWorkshops = state is WorkshopListLoaded
        ? state.workshops
        : <WorkshopResponseModel>[];

    // Filter workshops based on selection
    final currentUser = UserHelper.userNotifier.value;
    final workshops = _isMyWorkshops
        ? allWorkshops // Show all for "my own" (already filtered by API)
        : allWorkshops.where((workshop) {
            // For "Suggested", show only workshops that are NOT owned by current user
            return currentUser == null ||
                workshop.createdBy == null ||
                currentUser.id != workshop.createdBy;
          }).toList();

    if (workshops.isEmpty && state is! WorkshopLoading) {
      return Center(
        child: Text(
          'noWorkshopsFound'.tr(),
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: 20.h),
        itemCount: workshops.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 159.w / 150.h,
        ),
        itemBuilder: (context, index) {
          final workshop = workshops[index];
          final isOwner =
              currentUser != null &&
              workshop.createdBy != null &&
              currentUser.id == workshop.createdBy;

          return WorkshopCard(
            title: workshop.name,
            talents: workshop.specialization,
            date: _formatDate(workshop.startDate),
            imageUrl: workshop.coverImage?.isNotEmpty ?? false
                ? (workshop.coverImage?.startsWith('http') ?? false)
                      ? workshop.coverImage ?? ''
                      : AppUrls.storageImageLink(workshop.coverImage ?? '')
                : 'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=400',
            showMenu:
                isOwner &&
                _isMyWorkshops, // Only show menu for "my own" workshops
            onTap: () {
              setState(() {
                _selectedWorkshopId = workshop.id;
                // For "Suggested" mode, always use userApply mode (to show Apply button)
                // For "my own" mode, use ownerManage if user is owner
                if (_isMyWorkshops && isOwner) {
                  _mode = WorkShopDetailsMode.ownerManage;
                } else {
                  _mode = WorkShopDetailsMode
                      .userApply; // Show Apply button for suggested workshops
                }
                _showDetails = true;
                // Hide floating button when opening details
                widget.onShowFloatingButtonChanged?.call(false);
                // Fetch worshop details
                _workshopCubit.getWorkshopById(workshop.id);
              });
            },
            onEdit: () {
              openAddWorkshop(workshopToUpdate: workshop);
            },
            onDelete: () {
              // context.pop();
              _workshopCubit.deleteWorkshop(workshop.id);
            },
          );
        },
      ),
    );
  }
}
