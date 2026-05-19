import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/pending_approval/presentation/widgets/pending_approval_overlay.dart';
import '../cubit/home_enterprise_cubit.dart';
import '../widgets/home_enterprise_body.dart';

import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';

class HomeEnterpriseScreen extends StatelessWidget {
  const HomeEnterpriseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the app-level cubit instead of creating a new one
    return BlocProvider.value(
      value: context.read<HomeEnterpriseCubit>(),
      child: PendingApprovalOverlay(
        child: BlocProvider.value(
          value: getIt<NotificationsCubit>(),
          child: Scaffold(body: HomeEnterpriseBody()),
        ),
      ),
    );
  }
}
