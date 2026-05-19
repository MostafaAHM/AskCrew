import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart'
    as enterprise;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Actors section with horizontal scrollable list
class ActorsSectionWidget extends StatelessWidget {
  final List<enterprise.MovieActorModel> actors;

  const ActorsSectionWidget({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actors'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.lightMainText,
            fontSize: 16.sp,
          ),
        ),
        12.height,
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            separatorBuilder: (_, __) => 16.horizontalSpace,
            itemBuilder: (context, index) {
              final actor = actors[index];
              return ActorItemWidget(actor: actor);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual actor item widget
class ActorItemWidget extends StatelessWidget {
  final enterprise.MovieActorModel actor;

  const ActorItemWidget({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundImage: actor.image != null
              ? NetworkImage(actor.image!)
              : null,
          child: actor.image == null ? Icon(Icons.person, size: 28.sp) : null,
        ),
        5.height,
        SizedBox(
          width: 80.w,
          child: Text(
            actor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }
}
