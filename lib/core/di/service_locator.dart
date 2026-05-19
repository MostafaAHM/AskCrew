import 'package:aflam/features/enter_prise/community_enterprise/data/repo/questions/question_repo_impl.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/routes/navigation_service.dart';
import '../../features/auth/enterprise/enterprise_auth_flow/data/repository/enterprise_repository.dart';
import '../../features/auth/enterprise/enterprise_auth_flow/data/repository/enterprise_repository_impl.dart';

import '../../features/auth/enterprise/enterprise_auth_flow/presentation/cubit/register_enterprise/cubit/register_enterprise_cubit.dart';
import '../../features/auth/forget_password/data/repository/forget_password_repository.dart';
import '../../features/auth/forget_password/data/repository/forget_password_repository_impl.dart';
import '../../features/auth/forget_password/presentation/cubit/forget_password_cubit.dart';
import '../../features/auth/login/data/repo/login_repository.dart';
import '../../features/auth/login/data/repo/login_repository_impl.dart';
import '../../features/auth/login/presentation/cubit/login_cubit.dart';
import '../../features/auth/logout/data/repository/logout_repository.dart';
import '../../features/auth/logout/data/repository/logout_repository_impl.dart';
import '../../features/auth/logout/presentation/cubit/logout_cubit.dart';
import '../../features/enter_prise/community_enterprise/data/repo/jops/get_all_jops_repo.dart';
import '../../features/enter_prise/community_enterprise/data/repo/jops/get_all_jops_repo_impl.dart';
import '../../features/enter_prise/community_enterprise/data/repo/questions/question_repo.dart';
import '../../features/enter_prise/community_enterprise/presentation/cubit/jops/cubit/get_all_jops_cubit.dart';
import '../../features/enter_prise/community_enterprise/presentation/cubit/questions/cubit/questions_cubit.dart';
import '../../features/shared/plans/data/repo/plan_repository.dart';
import '../../features/shared/plans/data/repo/plan_repository_impl.dart';
import '../../features/shared/plans/data/repo/activate_plan_repository.dart';
import '../../features/shared/plans/data/repo/activate_plan_repository_impl.dart';
import '../../features/shared/plans/presentation/cubit/get_all_plan_cubit.dart';
import '../../features/shared/plans/presentation/cubit/activate_plan_cubit.dart';
import '../../features/auth/student/register_student/data/repository/student_repository.dart';
import '../../features/auth/student/register_student/data/repository/student_repository_impl.dart';
import '../../features/auth/student/register_student/presentation/cubit/cubit/register_student_cubit.dart';
import '../../features/auth/viewer/register_viewer/data/repo/register_repository.dart';
import '../../features/auth/viewer/register_viewer/data/repo/register_repository_impl.dart';
import '../../features/auth/viewer/register_viewer/data/services/google_auth_service.dart';
import '../../features/auth/viewer/register_viewer/presentation/cubit/signup_cubit.dart';
import '../../features/auth/reset_password/data/repository/reset_password_repository.dart';
import '../../features/auth/reset_password/data/repository/reset_password_repository_impl.dart';
import '../../features/auth/reset_password/presentation/cubit/reset_password_cubit.dart';
import '../../features/auth/verification/data/repository/verify_otp_repository.dart';
import '../../features/auth/verification/data/repository/verify_otp_repository_impl.dart';
import '../../features/auth/verification/presentation/cubit/validate_otp_code/verify_otp_cubit.dart';
import '../../features/shared/rewards/data/repository/reward_history_repository.dart';
import '../../features/shared/rewards/data/repository/reward_history_repository_impl.dart';
import '../../features/shared/rewards/data/repository/rewards_repository.dart';
import '../../features/shared/rewards/data/repository/rewards_repository_impl.dart';
import '../../features/shared/payment/data/repository/payment_repository.dart';
import '../../features/shared/payment/data/repository/payment_repository_impl.dart';
import '../../features/shared/payment/data/repository/watermark_payment_repository.dart';
import '../../features/shared/payment/data/repository/watermark_payment_repository_impl.dart';
import '../../features/shared/payment/presentation/cubit/payment_cubit.dart';
import '../../features/shared/payment/presentation/cubit/watermark_payment_cubit.dart';
import '../../features/chat/data/repo/chat_repository.dart';
import '../../features/chat/data/repo/chat_repository_impl.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/categories_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/categories_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/categories_cubit.dart';
import '../../features/shared/categories/data/repo/categories_repository.dart'
    as shared_categories;
import '../../features/shared/categories/data/repo/categories_repository_impl.dart'
    as shared_categories_repo;
import '../../features/shared/categories/presentation/cubit/categories_cubit.dart'
    as shared_categories_cubit;
import '../helpers/shared_pref_local_storage.dart';
import '../network/dio_service.dart';
import '../video_upload/data/video_upload_service.dart';

import '../video_upload/presentation/cubit/video_upload_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_movie_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_movie_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/create_movie_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_series_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_series_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/create_series_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_season_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_season_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/create_season_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_episode_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_episode_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/create_episode_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_movies_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_movies_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/get_movies_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_trending_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_trending_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_movie_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_movie_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/update_movie_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/delete_movie_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/delete_movie_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/delete_movie_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_seasons_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_seasons_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/get_seasons_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_episodes_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_episodes_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/get_episodes_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_series_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_series_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/get_series_cubit.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/content_management_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_advertise_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/create_advertise_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/create_advertise_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_advertise_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_advertise_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/update_advertise_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_advertises_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/get_advertises_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/get_advertises_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/delete_advertise_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/delete_advertise_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/delete_advertise_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_series_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_series_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/update_series_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_season_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_season_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/update_season_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_episode_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/update_episode_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/update_episode_cubit.dart';
import '../../features/enter_prise/work_enterprise/data/repository/workshop/workshop_repository.dart';
import '../../features/enter_prise/work_enterprise/data/repository/workshop/workshop_repository_impl.dart';
import '../../features/enter_prise/booking_enterprise/data/repository/booking_repository.dart';
import '../../features/enter_prise/booking_enterprise/data/repository/booking_repository_impl.dart';
import '../../features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import '../../features/enter_prise/booking_enterprise/presentation/cubit/booking_cubit.dart';
import '../../features/enter_prise/profile_enterprise/data/repository/profile_repository.dart';
import '../../features/enter_prise/profile_enterprise/data/repository/profile_repository_impl.dart';
import '../../features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import '../../features/shared/change_password/data/repository/change_password_repository.dart';
import '../../features/shared/change_password/data/repository/change_password_repository_impl.dart';
import '../../features/shared/change_password/presentation/cubit/change_password_cubit.dart';
import '../../features/shared/delete_account/data/repository/delete_account_repository.dart';
import '../../features/shared/delete_account/data/repository/delete_account_repository_impl.dart';
import '../../features/shared/delete_account/presentation/cubit/delete_account_cubit.dart';
import '../../features/shared/swap_accounts/data/repository/swap_account_repository.dart';
import '../../features/shared/swap_accounts/data/repository/swap_account_repository_impl.dart';
import '../../features/shared/swap_accounts/presentation/cubit/swap_account_cubit.dart';
import '../../core/video_player/data/repository/video_player_repository.dart';
import '../../core/video_player/data/repository/video_player_repository_impl.dart';
import '../../core/video_player/data/repository/content_video_token_repository.dart';
import '../../core/video_player/data/repository/content_video_token_repository_impl.dart';
import '../../core/video_player/presentation/cubit/video_player_cubit.dart';
import '../../core/video_player/presentation/cubit/content_video_token_cubit.dart';
import '../../features/viewer/home_viewer/data/repository/banner_repository.dart';
import '../../features/viewer/home_viewer/data/repository/banner_repository_impl.dart';
import '../../features/viewer/home_viewer/presentation/cubit/banner_cubit.dart';
import '../../features/viewer/home_viewer/data/repository/movies_with_series_repository.dart';
import '../../features/viewer/home_viewer/data/repository/movies_with_series_repository_impl.dart';
import '../../features/viewer/home_viewer/presentation/cubit/movies_with_series_cubit.dart';
import '../../features/viewer/explore_viewer/data/repository/explore_repository.dart';
import '../../features/viewer/explore_viewer/presentation/cubit/explore_cubit.dart';
import '../../features/viewer/favorites/data/repository/favorites_repository.dart';
import '../../features/viewer/favorites/data/repository/favorites_repository_impl.dart';
import '../../features/viewer/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/enter_prise/profile_enterprise/presentation/cubit/recent_transactions/recent_transactions_cubit.dart';
import '../../features/enter_prise/profile_enterprise/presentation/cubit/user_stats_cubit.dart';
import '../../features/shared/rewards/presentation/cubit/reward_history_cubit.dart';
import '../../features/shared/rewards/presentation/cubit/rewards_cubit.dart';
import '../../features/viewer/continue_watching/data/repo/continue_watching_repository.dart';
import '../../features/viewer/continue_watching/data/repository/continue_watching_repository_impl.dart';
import '../../features/viewer/continue_watching/presentation/cubit/continue_watching_cubit.dart';
import '../../features/shared/notifications/data/services/notifications_stream_service.dart';
import '../../features/shared/notifications/data/repository/notifications_repository.dart';
import '../../features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/viewer/home_search/presentation/cubit/home_search_cubit.dart';
import '../../features/shared/notifications/data/services/local_notifications_service.dart';
import '../../features/shared/notifications/data/services/fcm_service.dart';
import '../../features/enter_prise/profile_enterprise/presentation/cubit/edit_profile/enterprise_edit_profile_cubit.dart';
import '../../features/student/profile_student/data/repository/student_profile_repository.dart';
import '../../features/student/profile_student/data/repository/student_profile_repository_impl.dart';
import '../../features/student/profile_student/presentation/cubit/edit_profile/student_edit_profile_cubit.dart';
import '../../features/viewer/menu_viewer/data/repository/viewer_profile_repository.dart';
import '../../features/viewer/menu_viewer/data/repository/viewer_profile_repository_impl.dart';
import '../../features/viewer/menu_viewer/presentation/cubit/edit_profile/viewer_edit_profile_cubit.dart';
import '../../features/shared/talent_profile/data/datasource/talent_profile_remote_ds.dart';
import '../../features/shared/talent_profile/data/repo/talent_profile_repo.dart';
import '../../features/shared/talent_profile/presentation/cubit/talent_profile_cubit.dart';
import '../../features/shared/withdraw/data/repository/withdraw_repository.dart';
import '../../features/shared/withdraw/data/repository/withdraw_repository_impl.dart';
import '../../features/shared/withdraw/presentation/cubit/withdraw_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initExternals();

  _initRemoteDataSources();
  _initRepositories();
  _initCubits();
}

//?Externals
Future<void> _initExternals() async {
  await SharedPref.init();
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage("${appDocDir.path}/.cookies/"),
    ignoreExpires: false,
  );

  getIt.registerLazySingleton<SharedPref>(() => SharedPref());
  getIt.registerLazySingleton<CookieJar>(() => cookieJar);
  getIt.registerLazySingleton<DioService>(
    () => DioService(cookieJar: cookieJar),
  );
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService());
  getIt.registerLazySingleton<LocalNotificationsService>(
    () => LocalNotificationsService(),
  );
  getIt.registerLazySingleton<NotificationsStreamService>(
    () => NotificationsStreamService(),
  );
  getIt.registerLazySingleton<FcmService>(() => FcmService());
}

//?Remote Sources
void _initRemoteDataSources() {
  //*countries
  // getIt.registerLazySingleton<CountryService>(() => CountryService());
  // getIt.registerLazySingleton<ChatRemoteDataSource>(
  //     () => ChatRemoteDataSourceImpl(FirebaseFirestore.instance));
}

//?Repositories
void _initRepositories() {
  //*Auth

  getIt.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl());
  getIt.registerLazySingleton<EnterpriseRepository>(
    () => EnterpriseRepositoryImpl(),
  );
  getIt.registerLazySingleton<VerifyOtpRepository>(
    () => VerifyOtpRepositoryImpl(),
  );
  getIt.registerLazySingleton<PlanRepository>(() => PlanRepositoryImpl());
  getIt.registerLazySingleton<ActivatePlanRepository>(
    () => ActivatePlanRepositoryImpl(),
  );

  getIt.registerLazySingleton<RegisterRepository>(
    () => RegisterRepositoryImpl(),
  );

  getIt.registerLazySingleton<LogoutRepository>(
    () => LogoutRepositoryImpl(getIt<GoogleAuthService>()),
  );

  getIt.registerLazySingleton<ForgetPasswordRepository>(
    () => ForgetPasswordRepositoryImpl(),
  );

  getIt.registerLazySingleton<ResetPasswordRepository>(
    () => ResetPasswordRepositoryImpl(),
  );

  getIt.registerLazySingleton<QuestionRepo>(() => QuestionRepoImpl());

  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());

  // getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  // getIt.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl());

  // getIt.registerLazySingleton<CategoriesRepository>(
  //     () => CategoriesRepositoryImpl());
  getIt.registerLazySingleton<GetAllJopsRepo>(() => GetAllJopsRepoImpl());

  // //*Auctions
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepositoryImpl());

  // getIt.registerLazySingleton<CarRepository>(() => CarRepositoryImpl());
  // getIt.registerLazySingleton<CallSupportRepository>(
  //     () => CallSupportRepositoryImpl());
  // getIt.registerLazySingleton<MyAdsRepository>(() => MyAdsRepositoryImpl());
  // getIt.registerLazySingleton<NewAdRepository>(() => NewAdRepositoryImpl());
  // getIt.registerLazySingleton<AdsRepository>(() => AdDetailsRepositoryImpl());
  // getIt.registerLazySingleton<SearchAdRepository>(
  //     () => SearchAdRepositoryImpl());
  // getIt.registerLazySingleton<FavouritesRepository>(
  //     () => FavouritesRepositoryImpl());
  // getIt.registerLazySingleton<PackagesRepository>(
  //     () => PackagesRepositoryImpl());

  getIt.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl());
  getIt.registerLazySingleton<WatermarkPaymentRepository>(
    () => WatermarkPaymentRepositoryImpl(),
  );
  getIt.registerLazySingleton<RewardHistoryRepository>(
    () => RewardHistoryRepositoryImpl(),
  );
  getIt.registerLazySingleton<RewardsRepository>(() => RewardsRepositoryImpl());

  getIt.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt()),
  );
  // Shared categories repository for viewer
  getIt.registerLazySingleton<shared_categories.CategoriesRepository>(
    () => shared_categories_repo.CategoriesRepositoryImpl(),
  );
  getIt.registerLazySingleton<VideoUploadService>(() => VideoUploadService());
  getIt.registerLazySingleton<CreateMovieRepository>(
    () => CreateMovieRepositoryImpl(),
  );
  getIt.registerLazySingleton<CreateSeriesRepository>(
    () => CreateSeriesRepositoryImpl(),
  );
  getIt.registerLazySingleton<CreateSeasonRepository>(
    () => CreateSeasonRepositoryImpl(),
  );
  getIt.registerLazySingleton<CreateEpisodeRepository>(
    () => CreateEpisodeRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateMovieRepository>(
    () => UpdateMovieRepositoryImpl(),
  );
  getIt.registerLazySingleton<DeleteMovieRepository>(
    () => DeleteMovieRepositoryImpl(),
  );
  getIt.registerLazySingleton<GetMoviesRepository>(
    () => GetMoviesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetTrendingRepository>(
    () => GetTrendingRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetSeasonsRepository>(
    () => GetSeasonsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetEpisodesRepository>(
    () => GetEpisodesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetSeriesRepository>(
    () => GetSeriesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<CreateAdvertiseRepository>(
    () => CreateAdvertiseRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateAdvertiseRepository>(
    () => UpdateAdvertiseRepositoryImpl(),
  );
  getIt.registerLazySingleton<GetAdvertisesRepository>(
    () => GetAdvertisesRepositoryImpl(),
  );
  getIt.registerLazySingleton<DeleteAdvertiseRepository>(
    () => DeleteAdvertiseRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateSeriesRepository>(
    () => UpdateSeriesRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateSeasonRepository>(
    () => UpdateSeasonRepositoryImpl(),
  );
  getIt.registerLazySingleton<UpdateEpisodeRepository>(
    () => UpdateEpisodeRepositoryImpl(),
  );
  getIt.registerLazySingleton<WorkshopRepository>(
    () => WorkshopRepositoryImpl(),
  );
  getIt.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl());
  // getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
  getIt.registerLazySingleton<ChangePasswordRepository>(
    () => ChangePasswordRepositoryImpl(),
  );
  getIt.registerLazySingleton<DeleteAccountRepository>(
    () => DeleteAccountRepositoryImpl(),
  );
  getIt.registerLazySingleton<SwapAccountRepository>(
    () => SwapAccountRepositoryImpl(),
  );
  getIt.registerLazySingleton<VideoPlayerRepository>(
    () => VideoPlayerRepositoryImpl(),
  );
  getIt.registerLazySingleton<ContentVideoTokenRepository>(
    () => ContentVideoTokenRepositoryImpl(),
  );
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(getIt<DioService>()),
  );
  getIt.registerLazySingleton<MoviesWithSeriesRepository>(
    () => MoviesWithSeriesRepositoryImpl(),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(),
  );
  getIt.registerLazySingleton<ContinueWatchingRepository>(
    () => ContinueWatchingRepositoryImpl(),
  );
}

//?Blocs

void _initCubits() {
  //*Auth

  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));
  getIt.registerFactory<RegisterEnterpriseCubit>(
    () => RegisterEnterpriseCubit(getIt()),
  );
  getIt.registerFactory<VerifyOtpCubit>(() => VerifyOtpCubit(getIt()));
  getIt.registerFactory<RegisterStudentCubit>(
    () => RegisterStudentCubit(getIt()),
  );

  getIt.registerFactory<SignupCubit>(() => SignupCubit(getIt()));

  getIt.registerFactory<LogoutCubit>(() => LogoutCubit(getIt()));

  getIt.registerFactory<ForgetPasswordCubit>(
    () => ForgetPasswordCubit(getIt()),
  );

  getIt.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(getIt()));
  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(getIt()),
  );
  getIt.registerFactory<DeleteAccountCubit>(() => DeleteAccountCubit(getIt()));
  getIt.registerFactory<SwapAccountCubit>(() => SwapAccountCubit(getIt()));
  getIt.registerFactory<GetAllPlanCubit>(() => GetAllPlanCubit(getIt()));
  getIt.registerFactory<ActivatePlanCubit>(() => ActivatePlanCubit(getIt()));

  getIt.registerFactory<QuestionsCubit>(() => QuestionsCubit(getIt()));
  // getIt.registerFactory<ProfileAuctionsCubit>(
  //   () => ProfileAuctionsCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<HomeCubit>(
  //   () => HomeCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<SearchHomeCubit>(
  //   () => SearchHomeCubit(
  //     repo: getIt(),
  //   ),
  // );
  getIt.registerFactory<GetAllJopsCubit>(() => GetAllJopsCubit(getIt()));
  // //*Auctions
  // getIt.registerFactory<AuctionsCubit>(
  //   () => AuctionsCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<NewAuctionCubit>(
  //   () => NewAuctionCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<BiddingCubit>(
  //   () => BiddingCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<LocationsCubit>(
  //   () => LocationsCubit(
  //     getIt(),
  //   ),
  // );
  // getIt.registerFactory<ChatRoomsBloc>(
  //   () => ChatRoomsBloc(
  //     getIt(),
  //   ),
  // );
  // getIt.registerFactory<ChatRoomBloc>(
  //   () => ChatRoomBloc(
  //     getIt(),
  //   ),
  // );
  // getIt.registerFactory<ChatBloc>(
  //   () => ChatBloc(
  //     chatRepository: getIt(),
  //   ),
  // );

  // getIt.registerFactory<CarCubit>(
  //   () => CarCubit(
  //     repository: getIt(),
  //   ),
  // );

  // getIt.registerFactory<CallSupportCubit>(
  //   () => CallSupportCubit(
  //     getIt(),
  //   ),
  // );
  // getIt.registerFactory<MyAdsCubit>(
  //   () => MyAdsCubit(
  //     getIt(),
  //   ),
  // );
  // getIt.registerFactory<NewAdCubit>(
  //   () => NewAdCubit(
  //     repository: getIt(),
  //   ),
  // );
  // getIt.registerFactory<SearchAdsCubit>(
  //   () => SearchAdsCubit(
  //     repository: getIt(),
  //     categoriesRepository: getIt<CategoriesRepository>(),
  //   ),
  // );

  // getIt.registerFactory<EditProfileCubit>(
  //   () => EditProfileCubit(repository: getIt()),
  // );

  // getIt.registerFactory<AdDetailsCubit>(
  //   () => AdDetailsCubit(adsRepository: getIt(), repository: getIt()),
  // );
  // getIt.registerFactory<FavCubit>(
  //   () => FavCubit(favouritesRepository: getIt()),
  // );
  // getIt.registerFactory<PackagesCubit>(
  //   () => PackagesCubit(repository: getIt()),
  // );

  getIt.registerFactory<PaymentCubit>(() => PaymentCubit(getIt()));
  getIt.registerFactory<WatermarkPaymentCubit>(
    () => WatermarkPaymentCubit(getIt()),
  );

  getIt.registerFactory<BannerCubit>(() => BannerCubit(getIt()));

  getIt.registerFactory<ExploreCubit>(() => ExploreCubit(getIt()));

  getIt.registerFactory<MoviesWithSeriesCubit>(
    () => MoviesWithSeriesCubit(getIt()),
  );

  getIt.registerFactory<FavoritesCubit>(() => FavoritesCubit(getIt()));

  // getIt.registerFactory<SavedSearchCubit>(
  //   () => SavedSearchCubit(getIt(), getIt()),
  // );
  // getIt.registerFactory<PromotedAdsCubit>(
  //   () => PromotedAdsCubit(repository: getIt()),
  // );
  // getIt.registerFactory<MyOrdersCubit>(
  //   () => MyOrdersCubit(repository: getIt()),
  // );

  // getIt.registerFactory<FollowedUsersCubit>(
  //   () => FollowedUsersCubit(repository: getIt()),
  // );

  // getIt.registerFactory<FaqCubit>(
  //   () => FaqCubit(repository: getIt()),
  // );

  // getIt.registerFactory<CarRealEstateHomeCubit>(
  //   () => CarRealEstateHomeCubit(repository: getIt()),
  // );

  // getIt.registerFactory<CarFilterOptionsCubit>(
  //   () => CarFilterOptionsCubit(getIt()),
  // );

  // //*Agents
  // getIt.registerFactory<CreateAgentCubit>(
  //   () => CreateAgentCubit(repository: getIt()),
  // );
  // getIt.registerFactory<ListAgentsCubit>(
  //   () => ListAgentsCubit(repository: getIt()),
  // );

  // getIt.registerFactory<CarFilterResultsCubit>(
  //   () => CarFilterResultsCubit(carRepository: getIt()),
  // );

  // getIt.registerFactory<CarBodyTypeCubit>(
  //   () => CarBodyTypeCubit(carRepository: getIt()),
  // );

  // getIt.registerFactory<SpecialCompaniesCubit>(
  //   () => SpecialCompaniesCubit(carRepository: getIt()),
  // );

  // getIt.registerFactory<ChangePasswordCubit>(
  //   () => ChangePasswordCubit(
  //     passwordRepository: getIt<PasswordRepository>(),
  //   ),
  // );

  // getIt.registerFactory<NotificationsCubit>(
  //   () => NotificationsCubit(
  //     repository: getIt<NotificationsRepository>(),
  //   ),
  // );

  // getIt.registerFactory<SettingsCubit>(
  //   () => SettingsCubit(
  //     settingsRepository: getIt<SettingsRepository>(),
  //   ),
  // );
  // getIt.registerFactory<CarGuideLatestCubit>(
  //   () => CarGuideLatestCubit(
  //     repository: getIt<CarRepository>(),
  //   ),
  // );
  // Chat
  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt()));

  getIt.registerFactory<CategoriesCubit>(() => CategoriesCubit(getIt()));
  // Shared categories cubit for viewer
  getIt.registerFactory<shared_categories_cubit.CategoriesCubit>(
    () => shared_categories_cubit.CategoriesCubit(
      getIt<shared_categories.CategoriesRepository>(),
    ),
  );

  getIt.registerFactory<VideoUploadCubit>(() => VideoUploadCubit(getIt()));

  getIt.registerFactory<CreateMovieCubit>(() => CreateMovieCubit(getIt()));
  getIt.registerFactory<CreateSeriesCubit>(() => CreateSeriesCubit(getIt()));
  getIt.registerFactory<CreateSeasonCubit>(() => CreateSeasonCubit(getIt()));
  getIt.registerFactory<CreateEpisodeCubit>(() => CreateEpisodeCubit(getIt()));
  getIt.registerFactory<GetMoviesCubit>(() => GetMoviesCubit(getIt()));
  getIt.registerFactory<UpdateMovieCubit>(() => UpdateMovieCubit(getIt()));
  getIt.registerFactory<DeleteMovieCubit>(() => DeleteMovieCubit(getIt()));
  getIt.registerFactory<GetSeasonsCubit>(() => GetSeasonsCubit(getIt()));
  getIt.registerFactory<GetEpisodesCubit>(() => GetEpisodesCubit(getIt()));
  getIt.registerFactory<GetSeriesCubit>(() => GetSeriesCubit(getIt()));
  getIt.registerFactory<CreateAdvertiseCubit>(
    () => CreateAdvertiseCubit(getIt()),
  );
  getIt.registerFactory<UpdateAdvertiseCubit>(
    () => UpdateAdvertiseCubit(getIt()),
  );
  getIt.registerFactory<GetAdvertisesCubit>(() => GetAdvertisesCubit(getIt()));
  getIt.registerFactory<DeleteAdvertiseCubit>(
    () => DeleteAdvertiseCubit(getIt()),
  );
  getIt.registerFactory<UpdateSeriesCubit>(() => UpdateSeriesCubit(getIt()));
  getIt.registerFactory<UpdateSeasonCubit>(() => UpdateSeasonCubit(getIt()));
  getIt.registerFactory<UpdateEpisodeCubit>(() => UpdateEpisodeCubit(getIt()));
  getIt.registerFactory<ContentManagementCubit>(
    () => ContentManagementCubit(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<WorkshopCubit>(() => WorkshopCubit(getIt()));
  getIt.registerFactory<BookingCubit>(() => BookingCubit(getIt()));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt()));
  getIt.registerFactory<VideoPlayerCubit>(() => VideoPlayerCubit(getIt()));
  getIt.registerFactory<ContentVideoTokenCubit>(
    () => ContentVideoTokenCubit(getIt()),
  );
  getIt.registerFactory<RecentTransactionsCubit>(
    () => RecentTransactionsCubit(getIt(), getIt()),
  );
  getIt.registerFactory<RewardsCubit>(
    () => RewardsCubit(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<UserStatsCubit>(() => UserStatsCubit(getIt()));
  getIt.registerFactory<RewardHistoryCubit>(() => RewardHistoryCubit(getIt()));
  getIt.registerFactory<ContinueWatchingCubit>(
    () => ContinueWatchingCubit(getIt()),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<DioService>()),
  );
  getIt.registerLazySingleton<NotificationsCubit>(
    () => NotificationsCubit(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<HomeSearchCubit>(() => HomeSearchCubit(getIt()));

  // // Edit Profile Dependencies
  // getIt.registerFactory<EnterpriseEditProfileCubit>(
  //   () => EnterpriseEditProfileCubit(profileRepository: getIt()),
  // );

  getIt.registerLazySingleton<StudentProfileRepository>(
    () => StudentProfileRepositoryImpl(),
  );
  getIt.registerFactory<StudentEditProfileCubit>(
    () => StudentEditProfileCubit(
      profileRepository: getIt<StudentProfileRepository>(),
      enterpriseRepository: getIt<EnterpriseRepository>(),
    ),
  );

  getIt.registerLazySingleton<ViewerProfileRepository>(
    () => ViewerProfileRepositoryImpl(),
  );
  getIt.registerFactory<ViewerEditProfileCubit>(
    () => ViewerEditProfileCubit(profileRepository: getIt()),
  );

  getIt.registerFactory<EnterpriseEditProfileCubit>(
    () => EnterpriseEditProfileCubit(
      profileRepository: getIt<ProfileRepository>(),
      enterpriseRepository: getIt<EnterpriseRepository>(),
    ),
  );

  // Talent Profile
  getIt.registerLazySingleton<TalentProfileRemoteDataSource>(
    () => TalentProfileRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TalentProfileRepository>(
    () => TalentProfileRepositoryImpl(getIt()),
  );
  getIt.registerFactory<TalentProfileCubit>(() => TalentProfileCubit(getIt()));

  // Withdraw / Collect Requests
  getIt.registerLazySingleton<WithdrawRepository>(
    () => WithdrawRepositoryImpl(),
  );
  getIt.registerFactory<WithdrawCubit>(() => WithdrawCubit(getIt()));
}
