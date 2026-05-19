import 'package:bloc/bloc.dart';

import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/enter_prise/home_enterprise/data/model/talent_model.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/data/repository/profile_repository.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/workshop/workshop_repository.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_trending_repository.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import '../../data/model/student_profile_model.dart';
import 'home_student_state.dart';

class HomeStudentCubit extends Cubit<HomeStudentState> {
  final ProfileRepository _profileRepository;
  final WorkshopRepository _workshopRepository;
  final GetTrendingRepository _trendingRepository;

  // Cache for previous data to show immediately
  HomeStudentLoaded? _cachedData;

  HomeStudentCubit({
    ProfileRepository? profileRepository,
    WorkshopRepository? workshopRepository,
    GetTrendingRepository? trendingRepository,
  }) : _profileRepository = profileRepository ?? getIt<ProfileRepository>(),
       _workshopRepository = workshopRepository ?? getIt<WorkshopRepository>(),
       _trendingRepository =
           trendingRepository ?? getIt<GetTrendingRepository>(),
       super(HomeStudentInitial()) {
    loadStudentData();
  }

  void loadStudentData({
    bool showCachedData = true,
    bool showLoading = false,
  }) async {
    // If we have cached data, show it immediately for better UX
    if (showCachedData && _cachedData != null) {
      emit(_cachedData!);
    } else if (showLoading) {
      emit(HomeStudentLoading());
    }
    // Otherwise, keep current state (Initial) and load in background
    try {
      final myProfileResult = await _profileRepository.getMyProfile();

      final user = myProfileResult.fold((error) {
        emit(HomeStudentError(error.toString()));
        return null;
      }, (user) => user);

      if (user == null) return;

      List<String>? profileImages;
      if (user.profile?.images != null && user.profile!.images!.isNotEmpty) {
        profileImages = user.profile!.images!
            .map((img) => img['image'])
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
      }

      String? getProfession(dynamic spec) {
        if (spec == null) return null;
        if (spec is String) return spec;
        if (spec is Map) {
          final values = spec.values.whereType<String>();
          return values.isNotEmpty ? values.join(', ') : null;
        }
        return spec.toString();
      }

      final studentProfile = StudentProfileModel(
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
        views: user.profile?.views ?? 0,
        jobApplicationsCount: user.profile?.jobApplicationsCount ?? 0,
        approvedJobApplicationsCount:
            user.profile?.approvedJobApplicationsCount ?? 0,
      );

      // Load talents (enterprises) and students in parallel
      final talentsResult = await _profileRepository.getAllProfiles(
        type: 'enterprise',
      );

      final studentsResult = await _profileRepository.getAllProfiles(
        type: 'student',
      );

      // Load workshops
      final workshopsResult = await _workshopRepository.getWorkshops(
        page: 1,
        pageSize: 10,
      );

      // Load trending content
      final trendingResult = await _trendingRepository.getTrending();

      List<TalentModel> talents = [];
      List<TalentModel> students = [];
      List<WorkshopResponseModel> workshops = [];
      List<MovieModel> trending = [];

      talentsResult.fold(
        (error) {
          // If error, use empty list (no dummy data)
          talents = [];
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

      workshopsResult.fold(
        (error) {
          // If error, use empty list (no dummy data)
          workshops = [];
        },
        (response) {
          workshops = response.results;
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

      final loadedState = HomeStudentLoaded(
        profile: studentProfile,
        talents: talents,
        students: students,
        workshops: workshops,
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
        emit(HomeStudentError(e.toString()));
      }
    }
  }

  List<TalentModel> _convertUsersToTalents(List<UserModel> users) {
    return users.map((user) => TalentModel.fromUserModel(user)).toList();
  }

  void refreshData() {
    loadStudentData(showCachedData: true);
  }
}
