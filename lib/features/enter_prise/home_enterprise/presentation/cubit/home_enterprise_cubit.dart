import 'package:bloc/bloc.dart';

import 'package:aflam/core/di/service_locator.dart';

import 'package:aflam/core/app_config/app_strings.dart';
import '../../data/model/enterprise_dummy_data.dart';
import '../../data/model/enterprise_profile_model.dart';
import '../../data/model/performance_metric_model.dart';
import '../../data/model/talent_model.dart';
import '../../data/model/workshop_model.dart';
import '../../../profile_enterprise/data/repository/profile_repository.dart';
import '../../../work_enterprise/data/repository/workshop/workshop_repository.dart';
import '../../../work_enterprise/data/repository/get_trending_repository.dart';
import '../../../work_enterprise/data/models/response/movie_model.dart';
import '../../../../auth/login/data/model/response/user_model.dart';
import 'home_enterprise_state.dart';

class HomeEnterpriseCubit extends Cubit<HomeEnterpriseState> {
  final ProfileRepository _profileRepository;
  final WorkshopRepository _workshopRepository;
  final GetTrendingRepository _trendingRepository;

  // Cache for previous data to show immediately
  HomeEnterpriseLoaded? _cachedData;

  HomeEnterpriseCubit({
    ProfileRepository? profileRepository,
    WorkshopRepository? workshopRepository,
    GetTrendingRepository? trendingRepository,
  }) : _profileRepository = profileRepository ?? getIt<ProfileRepository>(),
       _workshopRepository = workshopRepository ?? getIt<WorkshopRepository>(),
       _trendingRepository =
           trendingRepository ?? getIt<GetTrendingRepository>(),
       super(HomeEnterpriseInitial()) {
    loadEnterpriseData();
  }

  void loadEnterpriseData({
    bool showCachedData = true,
    bool showLoading = false,
  }) async {
    // If we have cached data, show it immediately for better UX
    if (showCachedData && _cachedData != null) {
      emit(_cachedData!);
    } else if (showLoading) {
      emit(HomeEnterpriseLoading());
    }
    // Otherwise, keep current state (Initial) and load in background
    try {
      // Load my profile
      final myProfileResult = await _profileRepository.getMyProfile();

      final user = myProfileResult.fold((error) {
        emit(HomeEnterpriseError(error.toString()));
        return null;
      }, (user) => user);

      if (user == null) return;

      // Extract images from profile
      List<String>? profileImages;
      if (user.profile?.images != null && user.profile!.images!.isNotEmpty) {
        profileImages = user.profile!.images!
            .map((img) => img['image'])
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
      }

      // Convert UserModel to EnterpriseProfileModel
      String? getProfession(dynamic spec) {
        if (spec == null) return null;
        if (spec is String) return spec;
        if (spec is Map) {
          final values = spec.values.whereType<String>();
          return values.isNotEmpty ? values.join(', ') : null;
        }
        return spec.toString();
      }

      final enterpriseProfile = EnterpriseProfileModel(
        id: user.id.toString(),
        name: user.fullname,
        profession: getProfession(user.profile?.specification) ?? '',
        profileImage: user.profilePhoto ?? '',
        isVerified: user.isVerified,
        waterMark: user.waterMark,
        rating: user.ratingMean ?? 0.0,
        reviewsCount: user.ratingCount ?? 0,
        isAvailable: user.isActive,
        images: profileImages,
      );

      // Create metrics from profile data
      final metrics = <PerformanceMetricModel>[];
      if (user.profile != null) {
        final profile = user.profile!;
        if (profile.views != null) {
          metrics.add(
            PerformanceMetricModel(
              id: 'views',
              type: 'views',
              label: AppStrings.homeViews,
              value: profile.views!.toString(),
            ),
          );
        }
        if (profile.totalBookings != null) {
          metrics.add(
            PerformanceMetricModel(
              id: 'bookings',
              type: 'bookings',
              label: AppStrings.homeBookings,
              value: profile.totalBookings!.toString(),
            ),
          );
        }
        if (profile.topWorkView != null) {
          metrics.add(
            PerformanceMetricModel(
              id: 'topWork',
              type: 'topWork',
              label: AppStrings.homeTopWork,
              value: profile.topWorkView!.toString(),
            ),
          );
        }
      }

      // Load talents (enterprises) and students in parallel
      // Note: Backend doesn't allow page/page_size for enterprise users, only 'type' filter
      final talentsResult = await _profileRepository.getAllProfiles(
        type: 'enterprise',
      );

      final studentsResult = await _profileRepository.getAllProfiles(
        type: 'student',
      );

      // Convert UserModel list to TalentModel list
      List<TalentModel> talents = [];
      List<TalentModel> students = [];

      talentsResult.fold(
        (error) {
          // If error, use dummy data as fallback
          talents = EnterpriseDummyData.dummyTalents;
        },
        (response) {
          talents = _convertUsersToTalents(response.results);
        },
      );

      studentsResult.fold(
        (error) {
          // If error, use empty list (no dummy data)
          students = [];
        },
        (response) {
          students = _convertUsersToTalents(response.results);
        },
      );

      // Load workshops from API
      final workshopsResult = await _workshopRepository.getWorkshops(
        page: 1,
        pageSize: 10,
      );

      // Load trending content
      final trendingResult = await _trendingRepository.getTrending();

      List<WorkshopModel> workshops = [];
      List<MovieModel> trending = [];
      workshopsResult.fold(
        (error) {
          // If error, use empty list (no dummy data)
          workshops = [];
        },
        (response) {
          // Convert WorkshopResponseModel to WorkshopModel
          workshops = response.results.map((workshop) {
            return WorkshopModel(
              id: workshop.id.toString(),
              title: workshop.name,
              instructor: workshop.createdByFullname ?? '—',
              date: workshop.startDate,
              imageUrl: workshop.coverImage ?? '',
              description: workshop.description,
            );
          }).toList();
        },
      );

      trendingResult.fold(
        (error) {
          // If error, use empty list (no dummy data)
          trending = [];
        },
        (response) {
          trending = response.results;
        },
      );

      final loadedState = HomeEnterpriseLoaded(
        profile: enterpriseProfile,
        metrics: metrics.isNotEmpty ? metrics : [],
        workshops: workshops,
        forRent: EnterpriseDummyData.dummyForRent,
        talents: talents,
        students: students,
        trending: trending,
      );

      // Cache the loaded data for next time
      _cachedData = loadedState;
      emit(loadedState);
    } catch (e) {
      // If error and we have cached data, show it instead of error
      if (_cachedData != null) {
        emit(_cachedData!);
      } else {
        emit(HomeEnterpriseError(e.toString()));
      }
    }
  }

  List<TalentModel> _convertUsersToTalents(List<UserModel> users) {
    return users.map((user) => TalentModel.fromUserModel(user)).toList();
  }

  void refreshData() {
    loadEnterpriseData(showCachedData: true);
  }
}
