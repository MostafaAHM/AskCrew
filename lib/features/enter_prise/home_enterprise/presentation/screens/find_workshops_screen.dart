import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/translation_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_state.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/widgets/workshop/work_shop_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import '../../../../enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';

class FindWorkshopsScreen extends StatelessWidget {
  final List<WorkshopResponseModel>? initialWorkshops;
  final bool isMyWorkshops;

  const FindWorkshopsScreen({
    super.key,
    this.initialWorkshops,
    this.isMyWorkshops = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<WorkshopCubit>()
            ..getWorkshops(refresh: true, isMyWorkshops: isMyWorkshops),
      child: Scaffold(
        backgroundColor: AppColors.lightBGColor,
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    isMyWorkshops
                        ? 'myWorkshops'.trOrFallback('My Workshops')
                        : 'findWorkshops'.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<WorkshopCubit, WorkshopState>(
                  builder: (context, state) {
                    if (state is WorkshopLoading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: GridView.builder(
                          padding: EdgeInsets.only(bottom: 24.h),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) => CustomShimmerWidget(
                            width: double.infinity,
                            height: 200.h,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
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
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                            16.height,
                            ElevatedButton(
                              onPressed: () {
                                context.read<WorkshopCubit>().getWorkshops(
                                  refresh: true,
                                );
                              },
                              child: Text('common_retry'.tr()),
                            ),
                          ],
                        ),
                      );
                    }

                    List<WorkshopResponseModel> workshops = [];
                    if (state is WorkshopListLoaded) {
                      workshops = state.workshops;
                    } else if (initialWorkshops != null) {
                      workshops = initialWorkshops!;
                    }

                    if (workshops.isEmpty) {
                      return Center(
                        child: Text(
                          'common_no_workshops_found'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: GridView.builder(
                        padding: EdgeInsets.only(bottom: 24.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: workshops.length,
                        itemBuilder: (context, index) {
                          final workshop = workshops[index];
                          return _WorkshopCard(
                            workshop: workshop,
                            onTap: () {
                              // Save cubit reference before navigation
                              final cubit = context.read<WorkshopCubit>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (newContext) => BlocProvider.value(
                                    value: cubit,
                                    child: WorkShopDetails(
                                      workshopId: workshop.id,
                                      mode: WorkShopDetailsMode.userApply,
                                      showAppBar: true,
                                      onBack: () =>
                                          Navigator.of(newContext).pop(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
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

class _WorkshopCard extends StatelessWidget {
  final WorkshopResponseModel workshop;
  final VoidCallback onTap;

  const _WorkshopCard({required this.workshop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(workshop.startDate);
    final instructor = workshop.createdByFullname ?? '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 130.h,
                width: double.infinity,
                color: const Color(0xFFE9E9E9),
                child:
                    (workshop.coverImage != null &&
                        workshop.coverImage!.isNotEmpty)
                    ? CustomCachedNetworkImage(
                        url: workshop.coverImage!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.event,
                          size: 42.sp,
                          color: AppColors.greyText,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          workshop.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTText,
                          ),
                        ),
                      ),
                      6.height,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.sp,
                            color: AppColors.greyText,
                          ),
                          4.width,
                          Flexible(
                            child: Text(
                              formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.height,
                      Text(
                        'BY/ $instructor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
