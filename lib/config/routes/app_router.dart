import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/config/routes/routing_observer.dart';
import 'package:aflam/features/shared/talent_profile/presentation/screens/talent_profile_args.dart';
import 'package:aflam/features/shared/talent_profile/presentation/screens/talent_profile_screen.dart';
import 'package:aflam/features/viewer/menu_viewer/presentation/screens/delete_account.dart';
import 'package:aflam/features/viewer/menu_viewer/presentation/screens/profile_viewer_screen.dart';
import 'package:aflam/features/viewer/menu_viewer/presentation/screens/viewer_profile_details_screen.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/screens/edit_enterprise_profile_screen.dart';
import 'package:aflam/features/student/profile_student/presentation/screens/edit_student_profile_screen.dart';
import 'package:aflam/features/viewer/menu_viewer/presentation/screens/edit_viewer_profile_screen.dart';
import 'package:aflam/features/viewer/menu_viewer/presentation/screens/technical_support.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/core/extensions/translation_extension.dart';

import '../../core/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../../core/widgets/movie_details/movie_details.dart';
import '../../features/auth/enterprise/enterprise_auth_flow/data/models/request/enterprise_basic_data.dart';
import '../../features/auth/enterprise/enterprise_auth_flow/presentation/views/register_enterprise_screen.dart';
import '../../features/auth/student/student_auth_flow/data/models/request/student_basic_data.dart';
import '../../features/auth/student/student_auth_flow/presentation/views/student_onboarding_view.dart';
import '../../features/auth/forget_password/presentation/views/forget_password_view.dart';
import '../../features/auth/student/register_student/presentation/screens/register_student_screen.dart';
import '../../features/auth/reset_password/presentation/views/reset_password_view.dart';
import '../../features/auth/verification/presentation/verify_otp_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/screen/booking_enterprise_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/screen/add_booking_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/screen/booking_details_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/screen/all_bookings_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/screen/rented_people_screen.dart';
import '../../features/enter_prise/booking_enterprise/presentation/cubit/booking_cubit.dart';
import '../../features/enter_prise/booking_enterprise/data/models/response/booking_item_response_model.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/enter_prise/community_enterprise/presentation/screens/community_screens.dart';
import '../../features/viewer/explore_viewer/presentation/screens/explore_viewer_screen.dart';
import '../../features/enter_prise/home_enterprise/presentation/screens/home_enterprise_screen.dart';

import '../../features/student/home_student/presentation/screens/home_student_screen.dart';
import '../../features/viewer/home_search/presentation/views/home_search_view.dart';
import '../../features/viewer/home_viewer/data/model/movies_with_series_model.dart';
import '../../features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import '../../features/enter_prise/work_enterprise/data/models/response/create_advertise_response_model.dart';
import '../../features/enter_prise/work_enterprise/data/models/response/advertise_model.dart';
import '../../features/enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';
import '../../features/viewer/continue_watching/presentation/cubit/continue_watching_cubit.dart';

import '../../features/viewer/home_viewer/presentation/screens/home_screen_viewer.dart';
import '../../features/viewer/home_viewer/presentation/screens/series_and_movies.dart';
import '../../features/viewer/menu_viewer/presentation/screens/change_language.dart';
import '../../features/viewer/menu_viewer/presentation/screens/change_password.dart';
import '../../features/viewer/menu_viewer/presentation/screens/favorite_artwork.dart';
import '../../features/viewer/menu_viewer/presentation/screens/history_screen.dart';
import '../../features/shared/swap_accounts/presentation/screens/swap_accounts_screen.dart';
import '../../features/shared/pending_approval/presentation/screens/pending_approval_screen.dart';
import '../../features/shared/onboarding/presentation/on_boarding.dart';
import '../../features/shared/payment/presentation/cubit/payment_cubit.dart';
import '../../features/shared/trending/presentation/screens/trending_screen.dart';
import '../../core/video_player/presentation/screens/trailer_player_screen.dart';
import '../../core/video_player/presentation/screens/vertical_trailer_player_screen.dart';
import '../../features/viewer/explore_viewer/data/models/explore_response_model.dart';
import '../../features/shared/payment/presentation/screens/payment_screen.dart';
import '../../features/shared/payment/presentation/screens/payment_webview_screen.dart';
import '../../features/auth/login/presentation/views/login_view.dart';
import '../../features/auth/viewer/register_viewer/presentation/views/signup_viewer.dart';
import '../../features/auth/viewer/register_viewer/presentation/views/complete_viewer_profile_view.dart';
import '../../features/auth/enterprise/enterprise_auth_flow/presentation/views/enterprise_onboarding_view.dart';
import '../../features/shared/splash/presentation/views/splash_view.dart';
import '../../core/di/service_locator.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/select_artwork_type_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/upload_movie_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/upload_series_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/add_actors_price_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/upload_advertise_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/add_advertise_details_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/workshop/add_workshop_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/workshop/workshop_applications_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/work_enterprise_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/profile_enterprise_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/your_profile_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/all_works_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/user_profile_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/recent_transactions_screen.dart';
import '../../features/enter_prise/profile_enterprise/presentation/screens/withdraw_screen.dart';
import '../../features/enter_prise/home_enterprise/presentation/screens/find_talent_student_screen.dart';
import '../../features/enter_prise/home_enterprise/presentation/screens/find_workshops_screen.dart';
import '../../features/enter_prise/home_enterprise/data/model/talent_model.dart';
import '../../features/auth/login/data/model/response/user_model.dart';
import '../../features/student/profile_student/presentation/screens/profile_student_screen.dart';
import '../../features/chat/presentation/screens/chat_rooms_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../core/video_upload/test/test_video_upload_screen.dart';
import '../../core/video_upload/presentation/cubit/video_upload_cubit.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/categories_cubit.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/movie_preview_screen.dart';
import '../../features/enter_prise/work_enterprise/presentation/screens/advertise_preview_screen.dart';
import '../../core/video_player/presentation/screens/video_player_screen.dart';
import '../../core/video_player/presentation/cubit/video_player_cubit.dart';
import '../../features/shared/rewards/presentation/screens/rewards_screen.dart';
import '../../features/shared/notifications/presentation/screens/notifications_screen.dart';
import '../../services/app_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _homeEnterpriseTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _homeViewerTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _explorerViewerTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _settingViewerTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _enterpriseMyAdsTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _enterpriseNewAdTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _enterpriseChatTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _enterpriseSettingsTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _studentHomeTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _studentMyAdsTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _studentNewAdTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _studentChatTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _studentSettingsTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static GoRouter router = GoRouter(
    observers: [GoRouterObserver()],
    navigatorKey: appNavigatorKey,
    initialLocation: Routes.splashScreen,
    routes: <RouteBase>[
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.editEnterpriseProfile,
        name: Routes.editEnterpriseProfile,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const EditEnterpriseProfileScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.editStudentProfile,
        name: Routes.editStudentProfile,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const EditStudentProfileScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.editViewerProfile,
        name: Routes.editViewerProfile,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const EditViewerProfileScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.appLocked,
        name: Routes.appLocked,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const Error404Screen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.splashScreen,
        name: Routes.splashScreen,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const SplashView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.moduleSelection,
        name: Routes.moduleSelection,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const OnBoardingScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.verifyOtp,
        name: Routes.verifyOtp,
        pageBuilder: (context, state) {
          final phone = state.uri.queryParameters['phone'];
          final email = state.uri.queryParameters['email'];
          final typeParam = state.uri.queryParameters['type'];
          VerifyOtpType type = VerifyOtpType.register;
          if (typeParam == 'forgetPassword') {
            type = VerifyOtpType.forgetPassword;
          } else if (typeParam == 'accountVerification') {
            type = VerifyOtpType.accountVerification;
          }
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: VerifyOtpScreen(type: type, phone: phone, email: email),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.notifications,
        name: Routes.notifications,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.chatMessages,
        name: Routes.chatMessages,
        pageBuilder: (context, state) {
          final roomId = int.parse(state.pathParameters['roomId']!);
          final extra = state.extra as Map<String, dynamic>?;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<ChatCubit>(),
              child: ChatScreen(
                roomId: roomId,
                roomName: extra?['roomName'] ?? 'Chat',
                otherUserImage: extra?['otherUserImage'],
                specification: extra?['specification'],
                otherUser: extra?['otherUser'],
              ),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.favoriteArtwork,
        name: Routes.favoriteArtwork,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const FavoriteArtworkScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.login,
        name: Routes.login,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const LoginView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.signup,
        name: Routes.signup,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const SignupView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.registerEnterprise,
        name: Routes.registerEnterprise,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const RegisterEnterpriseScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.forgetPassword,
        name: Routes.forgetPassword,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const ForgetPasswordView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.registerStudent,
        name: Routes.registerStudent,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const RegisterStudentScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.resetPassword,
        name: Routes.resetPassword,
        pageBuilder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: ResetPasswordView(code: code),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.enterpriseOnboarding,
        name: Routes.enterpriseOnboarding,
        pageBuilder: (context, state) {
          final basicData = state.extra as EnterpriseBasicData?;
          final isSwap = state.uri.queryParameters['swap'] == 'true';

          if (basicData == null && !isSwap) {
            // If no data provided, redirect to register enterprise screen
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: const RegisterEnterpriseScreen(),
            );
          }

          return screenWithFadeTransition(
            context: context,
            state: state,
            child: EnterpriseOnboardingView(basicData: basicData),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.studentOnboarding,
        name: Routes.studentOnboarding,
        pageBuilder: (context, state) {
          final basicData = state.extra as StudentBasicData?;
          final isSwap = state.uri.queryParameters['swap'] == 'true';

          if (basicData == null && !isSwap) {
            // If no data provided, redirect to register student screen
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: const RegisterStudentScreen(),
            );
          }

          return screenWithFadeTransition(
            context: context,
            state: state,
            child: StudentOnboardingView(basicData: basicData),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.completeViewerProfile,
        name: Routes.completeViewerProfile,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const CompleteViewerProfileView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.recentTransactions,
        name: Routes.recentTransactions,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const RecentTransactionsScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.withdraw,
        name: Routes.withdraw,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const WithdrawScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.rewards,
        name: Routes.rewards,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const RewardsScreen(),
        ),
      ),

      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.homeSearch,
        name: Routes.homeSearch,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const HomeSearchView(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.movieDetails,
        name: Routes.movieDetails,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final item = extra as MovieOrSeriesItem?;

          if (item == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('common_movie_not_found'.tr())),
              ),
            );
          }

          // Route logic: MovieDetailsScreens handles both movies and series
          // If contentType == "series" or isSeries == true, it's a series
          // Both are handled by the same screen which adapts based on item type
          final isSeries = item.isSeries || item.contentType == 'series';

          // Note: SeriesDetailsScreen doesn't exist, so MovieDetailsScreens handles both
          // The screen adapts UI and logic based on item.isSeries property
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<ContinueWatchingCubit>(),
              child: MovieDetailsScreens(item: item),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.changeLanguage,
        name: Routes.changeLanguage,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const ChangeLanguageScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.changePassword,
        name: Routes.changePassword,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.swapAccounts,
        name: Routes.swapAccounts,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const SwapAccountsScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.pendingApproval,
        name: Routes.pendingApproval,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const PendingApprovalScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.technicalSupport,
        name: Routes.technicalSupport,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const TechnicalSupportScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.viewerProfileDetails,
        name: Routes.viewerProfileDetails,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final user = extra is UserModel ? extra : null;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: ViewerProfileDetailsScreen(preloadedUser: user),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.deleteAccount,
        name: Routes.deleteAccount,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const DeleteAccountScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.historyScreen,
        name: Routes.historyScreen,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.chatRooms,
        name: Routes.chatRooms,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const ChatRoomsScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.userProfile,
        name: Routes.userProfile,
        pageBuilder: (context, state) {
          // Accept either UserModel or userId (int) as extra
          final extra = state.extra;
          UserModel? user;
          int? userId;

          if (extra is UserModel) {
            user = extra;
          } else if (extra is int) {
            userId = extra;
          } else if (state.uri.queryParameters.containsKey('id')) {
            userId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          }

          // If we have userId but no user, create minimal UserModel with just id
          // UserProfileScreen will fetch full profile from API
          if (userId != null && user == null) {
            user = UserModel(
              id: userId,
              email: '',
              fullname: '',
              mobilePhone: '',
              wallet: '0.00',
              points: 0,
              isVerified: false,
              isActive: false,
              type: '',
              typeInt: 0,
              dateJoined: DateTime.now(),
            );
          }

          if (user == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(body: Center(child: Text('User not found'))),
            );
          }
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: UserProfileScreen(user: user),
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.testVideoUpload,
        name: Routes.testVideoUpload,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => getIt<VideoUploadCubit>(),
            child: const TestVideoUploadScreen(),
          );
        },
      ),

      // Work Enterprise - Add Work Flow
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.selectArtworkType,
        name: Routes.selectArtworkType,
        pageBuilder: (context, state) => screenWithFadeTransition(
          context: context,
          state: state,
          child: const SelectArtworkTypeScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.uploadMovie,
        name: Routes.uploadMovie,
        pageBuilder: (context, state) {
          final movieToUpdate = state.extra as MovieModel?;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<VideoUploadCubit>(),
              child: UploadMovieScreen(movieToUpdate: movieToUpdate),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.addBooking,
        name: Routes.addBooking,
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final itemToUpdate = state.extra as BookingItemResponseModel?;
          // Try to get existing cubit from parent, otherwise create new one
          BookingCubit? bookingCubit;
          try {
            bookingCubit = context.read<BookingCubit>();
          } catch (e) {
            bookingCubit = getIt<BookingCubit>();
          }
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider.value(
              value: bookingCubit,
              child: AddBookingScreen(itemToUpdate: itemToUpdate),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.bookingDetails,
        name: Routes.bookingDetails,
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final item = state.extra as BookingItemResponseModel?;
          if (item == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('Booking item not found')),
              ),
            );
          }
          // Try to get existing BookingCubit from parent, otherwise create new one
          BookingCubit? bookingCubit;
          try {
            bookingCubit = context.read<BookingCubit>();
          } catch (e) {
            bookingCubit = getIt<BookingCubit>();
          }

          // Try to get existing ChatCubit from parent, otherwise create new one
          ChatCubit? chatCubit;
          try {
            chatCubit = context.read<ChatCubit>();
          } catch (e) {
            chatCubit = getIt<ChatCubit>();
          }

          return screenWithFadeTransition(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bookingCubit),
                BlocProvider.value(value: chatCubit),
                BlocProvider(create: (_) => getIt<PaymentCubit>()),
              ],
              child: BookingDetailsScreen(item: item),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.rentedPeople,
        name: Routes.rentedPeople,
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final item = state.extra as BookingItemResponseModel?;
          if (item == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('Booking item not found')),
              ),
            );
          }
          // Try to get existing BookingCubit from parent, otherwise create new one
          BookingCubit? bookingCubit;
          try {
            bookingCubit = context.read<BookingCubit>();
          } catch (e) {
            bookingCubit = getIt<BookingCubit>();
          }

          // Try to get existing ChatCubit from parent, otherwise create new one
          ChatCubit? chatCubit;
          try {
            chatCubit = context.read<ChatCubit>();
          } catch (e) {
            chatCubit = getIt<ChatCubit>();
          }

          return screenWithFadeTransition(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bookingCubit),
                BlocProvider.value(value: chatCubit),
              ],
              child: RentedPeopleScreen(item: item),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.allBookings,
        name: Routes.allBookings,
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state) {
          final item = state.extra as BookingItemResponseModel?;
          if (item == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('Booking item not found')),
              ),
            );
          }
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: AllBookingsScreen(item: item),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.uploadSeries,
        name: Routes.uploadSeries,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<CategoriesCubit>()),
            ],
            child: const UploadSeriesScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.uploadAdvertising,
        name: Routes.uploadAdvertising,
        pageBuilder: (context, state) {
          final advertiseToUpdate =
              state.extra as CreateAdvertiseResponseModel?;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<VideoUploadCubit>(),
              child: UploadAdvertiseScreen(
                advertiseToUpdate: advertiseToUpdate,
              ),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.addAdvertiseDetailsScreen,
        name: Routes.addAdvertiseDetailsScreen,
        pageBuilder: (context, state) {
          final advertiseData = state.extra as Map<String, dynamic>;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: AddAdvertiseDetailsScreen(advertiseData: advertiseData),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.addActorsPriceScreen,
        name: Routes.addActorsPriceScreen,
        pageBuilder: (context, state) {
          final movieData = state.extra as Map<String, dynamic>;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: AddActorsPriceScreen(movieData: movieData),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.moviePreview,
        name: Routes.moviePreview,
        pageBuilder: (context, state) {
          final content = state.extra;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: MoviePreviewScreen(content: content),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.advertisePreview,
        name: Routes.advertisePreview,
        pageBuilder: (context, state) {
          final advertise = state.extra as AdvertiseModel;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: AdvertisePreviewScreen(advertise: advertise),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.addWorkshop,
        name: Routes.addWorkshop,
        pageBuilder: (context, state) {
          final workshopToUpdate = state.extra as WorkshopResponseModel?;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: AddWorkshopScreen(workshopToUpdate: workshopToUpdate),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.workshopApplications,
        name: Routes.workshopApplications,
        pageBuilder: (context, state) {
          final workshopId = state.extra as int? ?? 0;
          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider.value(
              value: getIt<WorkshopCubit>(),
              child: WorkshopApplicationsScreen(workshopId: workshopId),
            ),
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.paymentScreen,
        name: Routes.paymentScreen,
        builder: (context, state) {
          final options = state.extra as PaymentScreenArgs?;
          if (options == null) {
            return Scaffold(
              body: Center(
                child: Text('common_payment_options_not_provided'.tr()),
              ),
            );
          }
          return BlocProvider(
            create: (context) => getIt<PaymentCubit>(),
            child: PaymentScreen(args: options),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.paymentWebView,
        name: Routes.paymentWebView,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final paymentUrl = extra?['paymentUrl'] as String?;
          final onPaymentSuccess = extra?['onPaymentSuccess'] as VoidCallback?;
          final onPaymentCancel = extra?['onPaymentCancel'] as VoidCallback?;

          if (paymentUrl == null || paymentUrl.isEmpty) {
            return Scaffold(
              body: Center(child: Text('Payment URL not provided')),
            );
          }

          return PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            onPaymentSuccess: onPaymentSuccess,
            onPaymentCancel: onPaymentCancel,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.videoPlayer,
        name: Routes.videoPlayer,
        builder: (context, state) {
          final contentType = state.pathParameters['contentType'] ?? 'movie';
          final contentIdStr = state.pathParameters['contentId'] ?? '0';
          final contentId = int.tryParse(contentIdStr) ?? 0;

          // Check if we should play trailer (from query parameters)
          final playTrailer =
              state.uri.queryParameters['playTrailer'] == 'true';

          final extra = state.extra;
          final onProgress = (extra is Map<String, dynamic>)
              ? extra['onProgress'] as Function(int)?
              : null;

          return BlocProvider(
            create: (context) => getIt<VideoPlayerCubit>(),
            child: VideoPlayerScreen(
              contentType: contentType,
              contentId: contentId,
              playTrailer: playTrailer,
              onProgress: onProgress,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.trailerPlayer,
        name: Routes.trailerPlayer,
        builder: (context, state) {
          final contentType =
              state.pathParameters['contentType'] ?? 'advertise';
          final contentIdStr = state.pathParameters['contentId'] ?? '0';
          final contentId = int.tryParse(contentIdStr) ?? 0;

          return BlocProvider(
            create: (context) => getIt<VideoPlayerCubit>(),
            child: TrailerPlayerScreen(
              contentType: contentType,
              contentId: contentId,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.verticalTrailerPlayer,
        name: Routes.verticalTrailerPlayer,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final items = extra['items'] as List<ExploreItemModel>;
          final initialIndex = extra['initialIndex'] as int;

          return BlocProvider(
            create: (context) => getIt<VideoPlayerCubit>(),
            child: VerticalTrailerPlayerScreen(
              items: items,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: appNavigatorKey,
        path: Routes.chat,
        name: Routes.chat,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          if (args == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('Chat arguments not provided')),
              ),
            );
          }

          final roomId = args['roomId'] as int?;
          final roomName = args['roomName'] as String? ?? '';
          final otherUserImage = args['otherUserImage'] as String?;
          final specification = args['specification'] as String?;
          final otherUser = args['otherUser'] as UserModel?;

          if (roomId == null) {
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: Scaffold(
                body: Center(child: Text('Room ID not provided')),
              ),
            );
          }

          // Try to get existing ChatCubit from parent, otherwise create new one
          ChatCubit? chatCubit;
          try {
            chatCubit = context.read<ChatCubit>();
          } catch (e) {
            chatCubit = getIt<ChatCubit>();
          }

          return screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider.value(
              value: chatCubit,
              child: ChatScreen(
                roomId: roomId,
                roomName: roomName,
                otherUserImage: otherUserImage,
                specification: specification,
                otherUser: otherUser,
              ),
            ),
          );
        },
      ),
      ..._findTalentStudentRoutes,
      StatefulShellRoute.indexedStack(
        key: GlobalKey(),
        parentNavigatorKey: appNavigatorKey,
        pageBuilder: (context, state, navigationShell) {
          context.read<BottomNavigationCubit>().navigationShell =
              navigationShell;
          return MaterialPage<void>(
            key: state.pageKey,
            child: BottomNavBar(shell: navigationShell),
          );
        },
        branches: [
          ..._viewerBranches,
          ..._enterpriseBranches,
          ..._studentBranches,
        ],
      ),
    ],
  );

  static List<StatefulShellBranch> get _viewerBranches => [
    StatefulShellBranch(
      navigatorKey: _homeViewerTabNavigatorKey,
      initialLocation: Routes.viewerHome,
      routes: [
        GoRoute(
          path: Routes.viewerHome,
          name: Routes.viewerHome,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: HomeScreenViewer(),
          ),
        ),

        GoRoute(
          path: Routes.seriesAndMovies,
          name: Routes.seriesAndMovies,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const SeriesAndMoviesScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _explorerViewerTabNavigatorKey,
      initialLocation: Routes.exploreViewer,
      routes: [
        GoRoute(
          path: Routes.exploreViewer,
          name: Routes.exploreViewer,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ExploreViewerScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _settingViewerTabNavigatorKey,
      initialLocation: Routes.prfileViewer,
      routes: [
        GoRoute(
          path: Routes.prfileViewer,
          name: Routes.prfileViewer,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ProfileViewerScreen(),
          ),
        ),
      ],
    ),
  ];

  static List<StatefulShellBranch> get _enterpriseBranches => [
    StatefulShellBranch(
      navigatorKey: _homeEnterpriseTabNavigatorKey,
      initialLocation: Routes.enterpriseHome,
      routes: [
        GoRoute(
          path: Routes.enterpriseHome,
          name: Routes.enterpriseHome,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const HomeEnterpriseScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _enterpriseMyAdsTabNavigatorKey,
      initialLocation: Routes.enterpriseExplore,
      routes: [
        GoRoute(
          path: Routes.enterpriseExplore,
          name: Routes.enterpriseExplore,
          pageBuilder: (context, state) {
            final tabIndexStr = state.uri.queryParameters['tabIndex'];
            final tabIndex = tabIndexStr != null
                ? int.tryParse(tabIndexStr) ?? 0
                : 0;
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: WorkEnterpriseScreen(initialTabIndex: tabIndex),
            );
          },
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _enterpriseNewAdTabNavigatorKey,
      initialLocation: Routes.enterpriseCommunity,
      routes: [
        GoRoute(
          path: Routes.enterpriseCommunity,
          name: Routes.enterpriseCommunity,
          pageBuilder: (context, state) {
            final tabIndexStr = state.uri.queryParameters['tabIndex'];
            final tabIndex = tabIndexStr != null
                ? int.tryParse(tabIndexStr) ?? 0
                : 0;
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: CommunityScreens(initialTabIndex: tabIndex),
            );
          },
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _enterpriseChatTabNavigatorKey,
      initialLocation: Routes.enterpriseBookings,
      routes: [
        GoRoute(
          path: Routes.enterpriseBookings,
          name: Routes.enterpriseBookings,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const BookingEnterpriseScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: _enterpriseSettingsTabNavigatorKey,
      initialLocation: Routes.enterpriseProfile,
      routes: [
        GoRoute(
          path: Routes.enterpriseProfile,
          name: Routes.enterpriseProfile,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ProfileEnterpriseScreen(),
          ),
        ),
        GoRoute(
          path: Routes.yourProfile,
          name: Routes.yourProfile,
          pageBuilder: (context, state) {
            final user = state.extra as UserModel?;
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: YourProfileScreen(user: user),
            );
          },
        ),
        GoRoute(
          path: Routes.allWorks,
          name: Routes.allWorks,
          pageBuilder: (context, state) {
            final user = state.extra as UserModel?;
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: AllWorksScreen(user: user!),
            );
          },
        ),
      ],
    ),
  ];

  // Find Talent and Find Student routes
  static List<GoRoute> get _findTalentStudentRoutes => [
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: Routes.findTalent,
      name: Routes.findTalent,
      pageBuilder: (context, state) {
        final items = state.extra as List<TalentModel>? ?? [];
        return screenWithFadeTransition(
          context: context,
          state: state,
          child: FindTalentStudentScreen(
            title: 'home_find_talent'.trOrFallback('Find Talent'),
            items: items,
            isTalent: true,
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: Routes.findStudent,
      name: Routes.findStudent,
      pageBuilder: (context, state) {
        final items = state.extra as List<TalentModel>? ?? [];
        return screenWithFadeTransition(
          context: context,
          state: state,
          child: FindTalentStudentScreen(
            title: 'home_find_student'.trOrFallback('Find Student'),
            items: items,
            isTalent: false,
          ),
        );
      },
    ),

    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: Routes.findWorkshops,
      name: Routes.findWorkshops,
      pageBuilder: (context, state) {
        final workshops = state.extra as List<WorkshopResponseModel>?;
        final isMyWorkshops =
            state.uri.queryParameters['myWorkshops'] == 'true';
        return screenWithFadeTransition(
          context: context,
          state: state,
          child: FindWorkshopsScreen(
            initialWorkshops: workshops,
            isMyWorkshops: isMyWorkshops,
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: Routes.trending,
      name: Routes.trending,
      pageBuilder: (context, state) => screenWithFadeTransition(
        context: context,
        state: state,
        child: const TrendingScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: appNavigatorKey,
      path: Routes.talentProfile,
      name: Routes.talentProfile,
      pageBuilder: (context, state) {
        final args = state.extra as TalentProfileArgs;
        return screenWithFadeTransition(
          context: context,
          state: state,
          child: TalentProfileScreen(args: args),
        );
      },
    ),
  ];

  static List<StatefulShellBranch> get _studentBranches => [
    // Home tab for student – نفس شاشة الـ Enterprise مؤقتاً
    StatefulShellBranch(
      navigatorKey: _studentHomeTabNavigatorKey,
      initialLocation: Routes.studentHome,
      routes: [
        GoRoute(
          path: Routes.studentHome,
          name: Routes.studentHome,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const HomeStudentScreen(),
          ),
        ),
      ],
    ),

    // Explore / My Ads tab – يستخدم WorkEnterpriseScreen مؤقتاً
    StatefulShellBranch(
      navigatorKey: _studentMyAdsTabNavigatorKey,
      initialLocation: Routes.studentExplore,
      routes: [
        GoRoute(
          path: Routes.studentExplore,
          name: Routes.studentExplore,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: WorkEnterpriseScreen(),
          ),
        ),
      ],
    ),

    // Community tab – نفس CommunityScreens
    StatefulShellBranch(
      navigatorKey: _studentNewAdTabNavigatorKey,
      initialLocation: Routes.studentCommunity,
      routes: [
        GoRoute(
          path: Routes.studentCommunity,
          name: Routes.studentCommunity,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: CommunityScreens(),
          ),
        ),
      ],
    ),

    // Bookings / Chats tab – نفس BookingEnterpriseScreen
    StatefulShellBranch(
      navigatorKey: _studentChatTabNavigatorKey,
      initialLocation: Routes.studentBookings,
      routes: [
        GoRoute(
          path: Routes.studentBookings,
          name: Routes.studentBookings,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const BookingEnterpriseScreen(),
          ),
        ),
      ],
    ),

    // Settings / Profile tab – نفس ProfileViewerScreen مؤقتاً
    StatefulShellBranch(
      navigatorKey: _studentSettingsTabNavigatorKey,
      initialLocation: Routes.studentProfile,
      routes: [
        GoRoute(
          path: Routes.studentProfile,
          name: Routes.studentProfile,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ProfileStudentScreen(),
          ),
        ),
      ],
    ),
  ];
}

CustomTransitionPage screenWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    transitionDuration: const Duration(milliseconds: 300),
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
