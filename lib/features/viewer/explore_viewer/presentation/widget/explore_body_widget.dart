import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../home_viewer/presentation/widgets/home_top_bar.dart';
import '../cubit/explore_cubit.dart';
import 'explore_videos_grid.dart';
import 'package:aflam/core/helpers/user_helper.dart';

class ExploreBodyWidget extends StatelessWidget {
  const ExploreBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserHelper.userNotifier,
      builder: (context, user, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GetIt.I<ExploreCubit>()..getExploreContent(),
            ),
          ],
          child: Builder(
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: REdgeInsets.symmetric(horizontal: 16.w),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ExploreCubit>().getExploreContent();
                    },
                    child: ListView(
                      children: [
                        HomeTopBar(),
                        10.height,
                        Center(
                          child: Text(
                            "Let's Explore".tr(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22.sp,
                                ),
                          ),
                        ),
                        20.height,
                        const ExploreVideosGrid(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
