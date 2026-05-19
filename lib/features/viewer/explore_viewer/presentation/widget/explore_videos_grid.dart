import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';
import 'explore_video_card.dart';
import '../cubit/explore_cubit.dart';
import '../../../../../../config/routes/routes.dart';

class ExploreVideosGrid extends StatelessWidget {
  const ExploreVideosGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        if (state is ExploreLoading) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              return CustomShimmerWidget(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(24.r),
              );
            },
          );
        }

        if (state is ExploreError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ExploreLoaded) {
          final items = state.items;

          if (items.isEmpty) {
            return const Center(child: Text('No content available'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ExploreVideoCard(
                item: item,
                index: index,
                onTap: () {
                  context.pushNamed(
                    Routes.verticalTrailerPlayer,
                    extra: {'items': items, 'initialIndex': index},
                  );
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
