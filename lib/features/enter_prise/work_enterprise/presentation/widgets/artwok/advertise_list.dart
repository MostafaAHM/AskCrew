import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/helpers/messages.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../config/routes/routes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';
import '../../cubit/get_advertises_cubit.dart';
import '../../cubit/get_advertises_state.dart';
import '../../cubit/content_management_cubit.dart';
import 'artwork_card.dart';
import '../../../data/models/response/create_advertise_response_model.dart';

class AdvertiseList extends StatelessWidget {
  const AdvertiseList({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<GetAdvertisesCubit>()..getAdvertises(),
        ),
        BlocProvider(create: (context) => getIt<ContentManagementCubit>()),
      ],
      child: const _AdvertiseListContent(),
    );
  }
}

class _AdvertiseListContent extends StatelessWidget {
  const _AdvertiseListContent();

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentManagementCubit, ContentManagementState>(
      listener: (context, state) {
        if (state is ContentManagementSuccess) {
          AppMessages.showSuccess(context, state.message);
          if (!state.message.toLowerCase().contains('deleted')) {
            context.read<GetAdvertisesCubit>().getAdvertises();
          }
        } else if (state is ContentManagementError) {
          AppMessages.showError(context, state.message);
        }
      },
      child: BlocBuilder<GetAdvertisesCubit, GetAdvertisesState>(
        builder: (context, state) {
          if (state is GetAdvertisesLoading) {
            return CustomShimmerWidget(
              width: double.infinity,
              height: 140.h,
              borderRadius: BorderRadius.circular(16.r),
            );
          } else if (state is GetAdvertisesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GetAdvertisesCubit>().getAdvertises();
                    },
                    child: Text('common_retry'.tr()),
                  ),
                ],
              ),
            );
          } else if (state is GetAdvertisesLoaded) {
            final advertisesList = state.advertises.where((a) => a.isOwner).toList();

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<GetAdvertisesCubit>().getAdvertises();
              },
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 80.h),
                itemCount: advertisesList.length,
                separatorBuilder: (_, __) => 6.height,
                itemBuilder: (context, index) {
                  final advertise = advertisesList[index];
                  return ArtworkCard(
                    title: advertise.name,
                    rating: advertise.ratingMean,
                    subscribers: advertise.subscribedCount,
                    date: _formatDate(advertise.createdAt),
                    views: advertise.viewsCount.toString(),
                    imageUrl: advertise.coverImage,
                    price: advertise.price,
                    isOwner: advertise.isOwner,
                    isReady: true,
                    onDelete: () {
                      context.read<GetAdvertisesCubit>().removeAdvertiseLocally(
                        advertise.id,
                      );
                      context.read<ContentManagementCubit>().deleteAdvertise(
                        advertise.id,
                      );
                    },
                    onEdit: () async {
                      final advertiseToUpdate = CreateAdvertiseResponseModel(
                        id: advertise.id,
                        name: advertise.name,
                        price: advertise.price,
                        coverImage: advertise.coverImage,
                        actors: advertise.actors
                            .map(
                              (a) => ActorResponseData(
                                name: a.name,
                                image: a.image,
                              ),
                            )
                            .toList(),
                        trailer: advertise.trailer,
                        viewsCount: advertise.viewsCount,
                        category: CategoryData(
                          id: advertise.category.id,
                          name: advertise.category.name,
                          image: advertise.category.image ?? '',
                        ),
                        createdAt: advertise.createdAt,
                        updatedAt: advertise.updatedAt,
                      );

                      final result = await context.pushNamed(
                        Routes.uploadAdvertising,
                        extra: advertiseToUpdate,
                      );

                      if (result == true && context.mounted) {
                        context.read<GetAdvertisesCubit>().getAdvertises();
                      }
                    },
                    onTap: () {
                      context.pushNamed(
                        Routes.advertisePreview,
                        extra: advertise,
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
