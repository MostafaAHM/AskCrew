import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:aflam/core/helpers/secure_local_storage.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/core/enums/subscription_duration.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_movies_repository.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_series_repository.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_advertises_repository.dart';

import '../../../register_student/data/model/student_request_model.dart';
import '../../../register_student/data/repository/student_repository.dart';
import '../../data/models/request/student_basic_data.dart';
import '../../data/models/response/academic_year_model.dart';
import '../../data/models/response/institute_model.dart';
import '../../data/models/response/student_onboarding_data.dart';
import '../../data/models/response/student_specification_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/experience_level_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart'
    hide WorkItem;
import 'student_onboarding_state.dart';

class StudentOnboardingCubit extends Cubit<StudentOnboardingState> {
  final StudentBasicData? _basicData;
  final StudentRepository _studentRepository;
  final bool _isSwapMode;

  StudentOnboardingCubit({
    StudentBasicData? basicData,
    required StudentRepository studentRepository,
    bool isSwapMode = false,
  }) : _basicData = basicData,
       _studentRepository = studentRepository,
       _isSwapMode = isSwapMode,
       super(StudentOnboardingInitial()) {
    _initializeOnboarding();
  }

  StudentOnboardingData _data = StudentOnboardingData(
    institutes: InstituteModel.getDefaultInstitutes(),
    specifications: [],
    academicYears: AcademicYearModel.getDefaultAcademicYears(),
    experienceLevels: ExperienceLevelModel.getDefaultExperienceLevels(),
    subscriptionDuration: SubscriptionDuration.monthly,
  );

  int _currentStep = 0;

  int? get selectedPlanId => _data.selectedPlanId;
  SubscriptionDuration get subscriptionDuration =>
      _data.subscriptionDuration ?? SubscriptionDuration.monthly;

  void _initializeOnboarding() {
    _fetchSpecifications();
  }

  Future<void> _fetchSpecifications() async {
    final result = await _studentRepository.getSpecifications();
    result.fold(
      (failure) {
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      },
      (specsMap) {
        final categories = specsMap.entries.map((e) {
          return SpecificationCategoryModel(
            categoryName: e.key,
            items: e.value
                .map((i) => SpecificationModel(id: i, name: i))
                .toList(),
          );
        }).toList();
        _data = _data.copyWith(specifications: categories);
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      },
    );
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
    }
  }

  // ────────── Step 0: Institutes ──────────
  void toggleInstitute(String instituteId) {
    final updatedInstitutes = _data.institutes.map((institute) {
      if (institute.id == instituteId) {
        return institute.copyWith(isSelected: !institute.isSelected);
      }
      return institute;
    }).toList();

    _data = _data.copyWith(institutes: updatedInstitutes);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  // ────────── Step 1: Specifications ──────────
  void toggleSpecification(String categoryName, String specificationId) {
    final updatedSpecs = _data.specifications.map((cat) {
      if (cat.categoryName == categoryName) {
        final updatedItems = cat.items.map((spec) {
          if (spec.id == specificationId) {
            return spec.copyWith(isSelected: !spec.isSelected);
          }
          return spec;
        }).toList();
        return cat.copyWith(items: updatedItems);
      }
      return cat;
    }).toList();

    _data = _data.copyWith(specifications: updatedSpecs);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void toggleCategoryExpanded(String categoryName) {
    final updatedSpecs = _data.specifications.map((cat) {
      if (cat.categoryName == categoryName) {
        return cat.copyWith(isExpanded: !cat.isExpanded);
      }
      return cat;
    }).toList();

    _data = _data.copyWith(specifications: updatedSpecs);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  List<String> getSelectedInstitutes() {
    return _data.institutes
        .where((institute) => institute.isSelected)
        .map((institute) => institute.name)
        .toList();
  }

  List<String> getSelectedSpecifications() {
    return _data.specifications
        .expand((cat) => cat.items)
        .where((spec) => spec.isSelected)
        .map((spec) => spec.name)
        .toList();
  }

  // ────────── Step 2: Academic Year ──────────
  void toggleAcademicYear(String academicYearId) {
    final updatedYears = _data.academicYears.map((year) {
      if (year.id == academicYearId) {
        return year.copyWith(isSelected: !year.isSelected);
      }
      return year;
    }).toList();

    _data = _data.copyWith(academicYears: updatedYears);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateGraduatedYear(String year) {
    _data = _data.copyWith(graduatedYear: year);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  // ────────── Step 3: Work / Personal Info / Social Media ──────────
  void updateCountry(String country) {
    _data = _data.copyWith(country: country);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateCity(String city) {
    _data = _data.copyWith(city: city);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateProfilePicture(String path) {
    _data = _data.copyWith(profilePicturePath: path);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateCvPath(String path) {
    _data = _data.copyWith(cvPath: path);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updatePersonalInfo(String personalInfo) {
    _data = _data.copyWith(personalInfo: personalInfo);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateFacebookLink(String link) {
    _data = _data.copyWith(facebookLink: link);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateInstagramLink(String link) {
    _data = _data.copyWith(instagramLink: link);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateLinkedinLink(String link) {
    _data = _data.copyWith(linkedinLink: link);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateYoutubeLink(String link) {
    _data = _data.copyWith(youtubeLink: link);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateEmailAddress(String email) {
    _data = _data.copyWith(emailAddress: email);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void toggleExperienceLevel(String levelId) {
    final updatedLevels = _data.experienceLevels.map((l) {
      return l.copyWith(isSelected: l.id == levelId);
    }).toList();

    _data = _data.copyWith(experienceLevels: updatedLevels);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void addPortfolioLink(String link) {
    if (link.isEmpty) return;
    final currentLinks = List<String>.from(_data.portfolioLinks);
    currentLinks.add(link);
    _data = _data.copyWith(portfolioLinks: currentLinks);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void removePortfolioLink(int index) {
    final currentLinks = List<String>.from(_data.portfolioLinks);
    if (index >= 0 && index < currentLinks.length) {
      currentLinks.removeAt(index);
      _data = _data.copyWith(portfolioLinks: currentLinks);
      emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
    }
  }

  void updateContentType(String type) {
    _data = _data.copyWith(
      contentType: type,
      objectId: null,
      selectableWorks: [],
    );
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
    fetchSelectableWorks(type);
  }

  void updateObjectId(String id) {
    _data = _data.copyWith(objectId: id);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateSelectedRole(String role) {
    _data = _data.copyWith(selectedRole: role);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  Future<void> searchContentCatalog(String query, {String? type}) async {
    if (query.trim().isEmpty) {
      _data = _data.copyWith(searchResults: []);
      emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
      return;
    }

    final result = await _studentRepository.searchContentCatalog(
      query,
      type: type,
    );
    result.fold(
      (failure) {
        _data = _data.copyWith(searchResults: []);
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      },
      (items) {
        _data = _data.copyWith(searchResults: items);
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      },
    );
  }

  void addSelectedWorkItem(ContentCatalogItem item) {
    final currentItems = List<SelectedWorkItem>.from(
      _data.selectedWorkItems ?? [],
    );
    if (currentItems.any((e) => e.id == item.id && e.type == item.type)) return;
    currentItems.add(
      SelectedWorkItem(
        id: item.id,
        type: item.type,
        name: item.name,
        poster: item.poster,
      ),
    );
    _data = _data.copyWith(selectedWorkItems: currentItems);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void removeSelectedWorkItem(int id, String type) {
    final currentItems = List<SelectedWorkItem>.from(
      _data.selectedWorkItems ?? [],
    );
    currentItems.removeWhere((e) => e.id == id && e.type == type);
    _data = _data.copyWith(selectedWorkItems: currentItems);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void updateWorkItemRole(int id, String type, String role) {
    final currentItems = List<SelectedWorkItem>.from(
      _data.selectedWorkItems ?? [],
    );
    final index = currentItems.indexWhere((e) => e.id == id && e.type == type);
    if (index != -1) {
      currentItems[index] = currentItems[index].copyWith(role: role);
      _data = _data.copyWith(selectedWorkItems: currentItems);
      emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
    }
  }

  void clearSearchResults() {
    _data = _data.copyWith(searchResults: []);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  Future<void> fetchSelectableWorks(String type) async {
    if (type == 'movie') {
      final repo = getIt<GetMoviesRepository>();
      final result = await repo.getMovies();
      result.fold((failure) {}, (movies) {
        final works = movies.results
            .map(
              (m) => WorkItem(
                id: m.id.toString(),
                name: m.name,
                posterPath: m.coverImage,
              ),
            )
            .toList();
        _data = _data.copyWith(
          selectableWorks: works,
          objectId: works.isNotEmpty ? works.first.id : null,
        );
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      });
    } else if (type == 'series') {
      final repo = getIt<GetSeriesRepository>();
      final result = await repo.getSeries();
      result.fold((failure) {}, (series) {
        final works = series.results
            .map(
              (s) => WorkItem(
                id: s.id.toString(),
                name: s.title,
                posterPath: s.coverPhoto,
              ),
            )
            .toList();
        _data = _data.copyWith(
          selectableWorks: works,
          objectId: works.isNotEmpty ? works.first.id : null,
        );
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      });
    } else if (type == 'advertise') {
      final repo = getIt<GetAdvertisesRepository>();
      final result = await repo.getAdvertises();
      result.fold((failure) {}, (ads) {
        final works = ads
            .map(
              (a) => WorkItem(
                id: a.id.toString(),
                name: a.name,
                posterPath: a.coverImage,
              ),
            )
            .toList();
        _data = _data.copyWith(
          selectableWorks: works,
          objectId: works.isNotEmpty ? works.first.id : null,
        );
        emit(
          StudentOnboardingInProgress(currentStep: _currentStep, data: _data),
        );
      });
    }
  }

  // ────────── Step 5: Subscription ──────────
  void selectSubscriptionDuration(SubscriptionDuration duration) {
    _data = _data.copyWith(subscriptionDuration: duration);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  void selectSubscriptionPlan(int planId) {
    _data = _data.copyWith(selectedPlanId: planId);
    emit(StudentOnboardingInProgress(currentStep: _currentStep, data: _data));
  }

  // ────────── Validation ──────────
  String? getValidationError() {
    switch (_currentStep) {
      case 0:
        if (getSelectedInstitutes().isEmpty) {
          return 'pleaseSelectInstitute'.tr();
        }
        if (getSelectedSpecifications().isEmpty) {
          return 'atLeastOneSpecificationMustBeSelected'.tr();
        }
        return null;
      case 1:
        if (_data.academicYears.where((year) => year.isSelected).isEmpty) {
          return 'pleaseSelectYourAcademicYear'.tr();
        }
        return null;
      case 2:
        if (!_data.experienceLevels.any((l) => l.isSelected)) {
          return 'pleaseChooseExperienceLevel'.tr();
        }
        if (_data.country == null || _data.country!.trim().isEmpty) {
          return 'pleaseEnterYourCountry'.tr();
        }
        if (_data.city == null || _data.city!.trim().isEmpty) {
          return 'pleaseEnterYourCity'.tr();
        }
        if (_data.profilePicturePath == null ||
            _data.profilePicturePath!.isEmpty) {
          return 'pleaseUploadYourPicture'.tr();
        }
        // Validate "My Work" - if any work selected, all must have roles
        final selectedItems = _data.selectedWorkItems ?? [];
        if (selectedItems.isNotEmpty) {
          final itemWithoutRole = selectedItems.where(
            (item) => item.role == null || item.role!.isEmpty,
          );
          if (itemWithoutRole.isNotEmpty) {
            return 'pleaseSelectYourWork'.tr();
          }
        }
        return null;
      case 3:
        if (_data.selectedPlanId == null) {
          return 'pleaseSelectSubscriptionPlan'.tr();
        }
        return null;
      default:
        return null;
    }
  }

  // ────────── Submit ──────────
  Future<void> submitOnboarding() async {
    emit(StudentOnboardingLoading());

    try {
      final selectedInstitutes = getSelectedInstitutes();
      final selectedSpecs = getSelectedSpecifications();
      final selectedAcademicYear = _data.academicYears
          .firstWhere((year) => year.isSelected)
          .name;

      final skills = _data.personalInfo ?? '';
      final planId = _data.selectedPlanId?.toString() ?? '1';

      File? cvFile;
      if (_data.cvPath != null && _data.cvPath!.isNotEmpty) {
        cvFile = File(_data.cvPath!);
      }

      File? profilePhoto;
      if (_data.profilePicturePath != null &&
          _data.profilePicturePath!.isNotEmpty) {
        profilePhoto = File(_data.profilePicturePath!);
      }

      int durationMonths = 1;
      if (_data.subscriptionDuration == SubscriptionDuration.yearly) {
        durationMonths = 12;
      }

      final requestModel = StudentRequestModel(
        email: _basicData?.email.trim() ?? '',
        password: _basicData?.password ?? '',
        fullname: _basicData?.fullname ?? '',
        mobilePhone: _basicData?.mobilePhone ?? '',
        institute: selectedInstitutes.isNotEmpty
            ? selectedInstitutes.first
            : '',
        specification: selectedSpecs.isNotEmpty ? selectedSpecs.first : '',
        academicYear: selectedAcademicYear,
        skills: skills,
        country: _data.country ?? '',
        city: _data.city ?? '',
        planId: planId,
        facebookLink: _data.facebookLink ?? '',
        instagramLink: _data.instagramLink ?? '',
        linkedinLink: _data.linkedinLink ?? '',
        youtubeLink: _data.youtubeLink ?? '',
        cv: cvFile,
        videos: null,
        images: null,
        profilePhoto: profilePhoto,
        personalInfo: _data.personalInfo,
        durationMonths: durationMonths,
        workItemsRoles: _data.selectedWorkItems?.isNotEmpty == true
            ? _data.selectedWorkItems
            : null,
        rolesContentType:
            _data.selectedWorkItems == null && _data.selectedRole != null
            ? _data.contentType
            : null,
        rolesObjectId:
            _data.selectedWorkItems == null && _data.selectedRole != null
            ? int.tryParse(_data.objectId ?? '')
            : null,
        roles: _data.selectedWorkItems == null && _data.selectedRole != null
            ? [_data.selectedRole!]
            : null,
        experienceLevel: _data.experienceLevels.any((l) => l.isSelected)
            ? _data.experienceLevels.firstWhere((l) => l.isSelected).name
            : null,
        portfolioLinks: _data.portfolioLinks.isNotEmpty
            ? _data.portfolioLinks
            : null,
      );

      final result = _isSwapMode
          ? await _studentRepository.completeStudentProfile(model: requestModel)
          : await _studentRepository.registerStudent(model: requestModel);

      result.fold((error) => emit(StudentOnboardingFailure(error.message)), (
        response,
      ) {
        String? paymentUrl;
        try {
          final dynamicResponse = response as dynamic;
          if (dynamicResponse.data != null) {
            final data = dynamicResponse.data as Map<String, dynamic>;
            final payment = data['payment'];
            if (payment != null && payment is Map<String, dynamic>) {
              final transaction = payment['transaction'];
              if (transaction != null && transaction is Map<String, dynamic>) {
                paymentUrl = transaction['url'] as String?;
              }
            }

            if (_isSwapMode) {
              UserModel? updatedUser;
              if (data.containsKey('id') && data.containsKey('email')) {
                updatedUser = UserModel.fromJson(data);
              } else if (data.containsKey('user')) {
                updatedUser = UserModel.fromJson(data['user']);
              }

              if (updatedUser != null) {
                UserHelper.setUser(updatedUser);
                SecureLocalStorage.write(
                  PrefsKeys.user,
                  jsonEncode(updatedUser.toJson()),
                );
              }
            }
          }
        } catch (e) {}

        final message =
            (response.message == null ||
                response.message!.isEmpty ||
                response.message!.toLowerCase() == 'null')
            ? 'studentRegisteredSuccessfully'.tr()
            : response.message!;
        emit(StudentOnboardingSuccess(message, paymentUrl: paymentUrl));
      });
    } catch (e) {
      emit(StudentOnboardingFailure(e.toString()));
    }
  }
}
