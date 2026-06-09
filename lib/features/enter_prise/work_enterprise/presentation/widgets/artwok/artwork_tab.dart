import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'advertise_list.dart';
import 'artwork_list.dart';
import '../segment_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../cubit/get_movies_cubit.dart';
import 'series_list.dart';
import '../../cubit/get_series_cubit.dart';
import '../../cubit/content_management_cubit.dart';

class ArtworkTab extends StatelessWidget {
  const ArtworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<GetMoviesCubit>()),
        BlocProvider(create: (context) => getIt<GetSeriesCubit>()),
        BlocProvider(create: (context) => getIt<ContentManagementCubit>()),
      ],
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final controller = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final current = controller.index;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SegmentButton(
                          text: 'Movie'.tr(),
                          selected: current == 0,
                          onTap: () => controller.animateTo(0),
                        ),
                        8.width,
                        SegmentButton(
                          text: 'Series'.tr(),
                          selected: current == 1,
                          onTap: () => controller.animateTo(1),
                        ),
                        8.width,
                        SegmentButton(
                          text: 'Advertise'.tr(),
                          selected: current == 2,
                          onTap: () => controller.animateTo(2),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            12.height,
            Expanded(
              child: TabBarView(
                children: [
                ArtworkList(),
                SeriesList(),
                AdvertiseList(),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
