import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../config/routes/routes.dart';
import '../../../../../../core/helpers/messages.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/get_series_cubit.dart';
import '../../cubit/content_management_cubit.dart';
import '../../screens/upload_series_screen.dart';

import '../../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';
import 'artwork_card.dart';

class SeriesList extends StatefulWidget {
  final Color orange;

  const SeriesList({super.key, required this.orange});

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  // Add scroll controller for pagination if needed later

  @override
  void initState() {
    super.initState();
    context.read<GetSeriesCubit>().getSeries();
  }

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
            context.read<GetSeriesCubit>().getSeries();
          }
        } else if (state is ContentManagementError) {
          AppMessages.showError(context, state.message);
        }
      },
      child: BlocBuilder<GetSeriesCubit, GetSeriesState>(
        builder: (context, state) {
          if (state is GetSeriesLoading) {
            return ListView.separated(
              padding: EdgeInsets.only(bottom: 80.h),
              itemCount: 6,
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (_, __) => CustomShimmerWidget(
                width: double.infinity,
                height: 140.h,
                borderRadius: BorderRadius.circular(16.r),
              ),
            );
          } else if (state is GetSeriesError) {
            return Center(child: Text(state.message));
          } else if (state is GetSeriesLoaded) {
            final seriesList = state.series.where((s) => s.isOwner).toList();

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<GetSeriesCubit>().getSeries();
              },
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 80.h),
                itemBuilder: (c, i) {
                  final series = seriesList[i];
                  return ArtworkCard(
                    orange: widget.orange,
                    date: _formatDate(series.createdAt),
                    imageUrl: series.coverPhoto ?? '',
                    rating: series.ratingMean ?? 0.0,
                    subscribers: series.subscribedCount,
                    title: series.title,
                    views: series.viewsCount.toString(),
                    price: series.price,
                    isOwner: series.isOwner,
                    isReady: series.isReady,
                    onDelete: () {
                      context.read<GetSeriesCubit>().removeSeriesLocally(
                        series.id,
                      );
                      context.read<ContentManagementCubit>().deleteSeries(
                        series.id,
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UploadSeriesScreen(seriesToEdit: series),
                        ),
                      );
                    },
                    onTap: () {
                      context.pushNamed(Routes.moviePreview, extra: series);
                    },
                  );
                },
                separatorBuilder: (_, __) => 6.height,
                itemCount: seriesList.length,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
