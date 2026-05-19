import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/app_config/app_colors.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../cubit/talent_profile_cubit.dart';
import '../cubit/talent_profile_state.dart';
import '../widgets/about_card.dart';
import '../widgets/info_row.dart';
import '../widgets/portfolio_section.dart';
import '../widgets/profile_header.dart';
import 'package:shimmer/shimmer.dart';

import 'package:go_router/go_router.dart';
import '../../../../../../config/routes/routes.dart';
import '../../../../chat/presentation/cubit/chat_cubit.dart';
import 'talent_profile_args.dart';

class TalentProfileScreen extends StatelessWidget {
  final TalentProfileArgs args;
  const TalentProfileScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<TalentProfileCubit>()..getTalentProfile(args.id),
        ),
        BlocProvider(create: (context) => getIt<ChatCubit>()),
      ],
      child: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.success &&
              state.selectedRoom != null) {
            final profileState = context.read<TalentProfileCubit>().state;
            String roomName = '';
            String? otherUserImage;
            String? specification;

            if (profileState is TalentProfileLoaded) {
              roomName = profileState.profile.name;
              otherUserImage = profileState.profile.imageUrl;
              specification = profileState.profile.jobTitle;
            }

            context.pushNamed(
              Routes.chatMessages,
              pathParameters: {'roomId': state.selectedRoom!.id.toString()},
              extra: {
                'roomName': roomName,
                'otherUserImage': otherUserImage,
                'specification': specification,
              },
            );
          } else if (state.status == ChatStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error opening chat'),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: BlocBuilder<TalentProfileCubit, TalentProfileState>(
            builder: (context, state) {
              if (state is TalentProfileLoading) {
                return const _TalentProfileShimmer();
              } else if (state is TalentProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      TextButton(
                        onPressed: () {
                          context.read<TalentProfileCubit>().getTalentProfile(
                            args.id,
                          );
                        },
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                );
              } else if (state is TalentProfileLoaded) {
                final profile = state.profile;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(profile: profile),
                      24.verticalSpace,
                      AboutCard(about: profile.about),
                      24.verticalSpace,
                      InfoRow(
                        icon: Icons.location_on_outlined,
                        text: profile.location,
                      ),
                      InfoRow(
                        icon: Icons.school_outlined,
                        text: profile.specialization,
                      ),
                      32.verticalSpace,
                      if (profile.works.isNotEmpty) ...[
                        Text(
                          'talent.profile.works'.tr(), // "Works" / "الأعمال"
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        16.verticalSpace,
                        PortfolioSection(works: profile.works),
                        32.verticalSpace,
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _TalentProfileShimmer extends StatelessWidget {
  const _TalentProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            CircleAvatar(radius: 60.r),
            16.verticalSpace,
            Container(height: 20.h, width: 150.w, color: Colors.white),
            8.verticalSpace,
            Container(height: 16.h, width: 100.w, color: Colors.white),
            24.verticalSpace,
            Container(
              height: 100.h,
              width: double.infinity,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
