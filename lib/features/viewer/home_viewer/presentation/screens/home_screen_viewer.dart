import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/shared/categories/presentation/cubit/categories_cubit.dart'
    as shared_categories_cubit;
import 'package:aflam/features/shared/payment/presentation/cubit/payment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../continue_watching/presentation/cubit/continue_watching_cubit.dart';
import '../cubit/banner_cubit.dart';
import '../widgets/home_body_viewer.dart';

class HomeScreenViewer extends StatelessWidget {
  const HomeScreenViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<shared_categories_cubit.CategoriesCubit>(),
        ),
        BlocProvider(create: (context) => getIt<BannerCubit>()),
        BlocProvider(create: (context) => getIt<PaymentCubit>()),
        BlocProvider(create: (context) => getIt<ContinueWatchingCubit>()),
        BlocProvider.value(value: getIt<NotificationsCubit>()),
      ],
      child: Scaffold(body: const SafeArea(child: HomeBodyViewer())),
    );
  }
}
