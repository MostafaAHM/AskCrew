import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import 'package:aflam/core/app_config/prefs_keys.dart';
import 'package:aflam/core/helpers/secure_local_storage.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import '../../../../../../core/enums/subscription_duration.dart';
import '../../data/models/request/enterprise_basic_data.dart';
import '../../data/models/request/enterprise_requst_model.dart';
import '../../data/models/response/enterprise_onboarding_data.dart';
import '../../data/models/response/specification_model.dart';
import '../../data/models/response/experience_level_model.dart';
import '../../data/repository/enterprise_repository.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../enter_prise/work_enterprise/data/repository/get_movies_repository.dart';
import '../../../../../enter_prise/work_enterprise/data/repository/get_series_repository.dart';
import '../../../../../enter_prise/work_enterprise/data/repository/get_advertises_repository.dart';

import 'enterprise_onboarding_state.dart';

class EnterpriseOnboardingCubit extends Cubit<EnterpriseOnboardingState> {
  final EnterpriseRepository _repository;
  final EnterpriseBasicData? _basicData;
  final bool _isSwapMode;

  EnterpriseOnboardingCubit({
    required EnterpriseRepository repository,
    EnterpriseBasicData? basicData,
    bool isSwapMode = false,
  }) : _repository = repository,
       _basicData = basicData,
       _isSwapMode = isSwapMode,
       super(EnterpriseOnboardingInitial()) {
    _initializeOnboarding();
  }

  int _currentStep = 0;

  EnterpriseOnboardingData _data = EnterpriseOnboardingData(
    specifications: [],
    experienceLevels: ExperienceLevelModel.getDefaultExperienceLevels(),
    subscriptionDuration: SubscriptionDuration.monthly,
  );

  void _initializeOnboarding() {
    _fetchSpecifications();
  }

  Future<void> _fetchSpecifications() async {
    final result = await _repository.getSpecifications();
    result.fold(
      (failure) {
        emit(
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
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
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
        );
      },
    );
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      emit(
        EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
      );
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(
        EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      emit(
        EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
      );
    }
  }

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
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void toggleCategoryExpanded(String categoryName) {
    final updatedSpecs = _data.specifications.map((cat) {
      if (cat.categoryName == categoryName) {
        return cat.copyWith(isExpanded: !cat.isExpanded);
      }
      return cat;
    }).toList();

    _data = _data.copyWith(specifications: updatedSpecs);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void selectExperienceLevel(String experienceLevelId) {
    final updatedLevels = _data.experienceLevels.map((level) {
      if (level.id == experienceLevelId) {
        return level.copyWith(isSelected: true);
      }
      return level.copyWith(isSelected: false);
    }).toList();

    _data = _data.copyWith(experienceLevels: updatedLevels);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void updatePersonalInfo(String personalInfo) {
    _data = _data.copyWith(personalInfo: personalInfo);
  }

  void updateCountry(String country) {
    _data = _data.copyWith(country: country);
  }

  void updateCity(String city) {
    _data = _data.copyWith(city: city);
  }

  void updateObjectId(String id) {
    _data = _data.copyWith(objectId: id);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void updateSelectedRole(String role) {
    _data = _data.copyWith(selectedRole: role);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  Future<void> searchContentCatalog(String query, {String? type}) async {
    if (query.trim().isEmpty) {
      _data = _data.copyWith(searchResults: []);
      emit(
        EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
      );
      return;
    }

    final result = await _repository.searchContentCatalog(query, type: type);
    result.fold(
      (failure) {
        _data = _data.copyWith(searchResults: []);
        emit(
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
        );
      },
      (items) {
        _data = _data.copyWith(searchResults: items);
        emit(
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
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
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void removeSelectedWorkItem(int id, String type) {
    final currentItems = List<SelectedWorkItem>.from(
      _data.selectedWorkItems ?? [],
    );
    currentItems.removeWhere((e) => e.id == id && e.type == type);
    _data = _data.copyWith(selectedWorkItems: currentItems);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void updateWorkItemRole(int id, String type, String role) {
    final currentItems = List<SelectedWorkItem>.from(
      _data.selectedWorkItems ?? [],
    );
    final index = currentItems.indexWhere((e) => e.id == id && e.type == type);
    if (index != -1) {
      currentItems[index] = currentItems[index].copyWith(role: role);
      _data = _data.copyWith(selectedWorkItems: currentItems);
      emit(
        EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
      );
    }
  }

  void clearSearchResults() {
    _data = _data.copyWith(searchResults: []);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  Future<void> fetchSelectableWorks(String type) async {
    // Show loading within the step if possible, but for now we just update the list
    _data = _data.copyWith(contentType: type, selectableWorks: []);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );

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
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
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
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
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
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
        );
      });
    }
  }

  void updateContentType(String type) {
    _data = _data.copyWith(
      contentType: type,
      objectId: null,
      selectableWorks: [],
    );
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
    fetchSelectableWorks(type);
  }

  void updateProfilePicture(String path) {
    _data = _data.copyWith(profilePicturePath: path);
  }

  void updateSelectedWork(String work) {
    _data = _data.copyWith(selectedWork: work);
  }

  void updateVideoFile(String path) {
    _data = _data.copyWith(videoFile: path);
  }

  void updateVideoId(String id) {
    _data = _data.copyWith(videoId: id);
  }

  void addPortfolioLink(String link) {
    final currentLinks = _data.portfolioLinks ?? [];
    _data = _data.copyWith(portfolioLinks: [...currentLinks, link]);
  }

  void removePortfolioLink(int index) {
    final currentLinks = _data.portfolioLinks ?? [];
    final updatedLinks = List<String>.from(currentLinks)..removeAt(index);
    _data = _data.copyWith(portfolioLinks: updatedLinks);
  }

  void selectSubscriptionPlan(int planId) {
    _data = _data.copyWith(selectedPlanId: planId);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  void selectSubscriptionDuration(SubscriptionDuration duration) {
    _data = _data.copyWith(subscriptionDuration: duration);
    emit(
      EnterpriseOnboardingInProgress(currentStep: _currentStep, data: _data),
    );
  }

  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _data.specifications.any(
          (cat) => cat.items.any((spec) => spec.isSelected),
        );
      case 1:
        return _data.experienceLevels.any((level) => level.isSelected);
      case 2:
        final bool isBasicInfoValid =
            _data.country != null &&
            _data.country!.trim().isNotEmpty &&
            _data.city != null &&
            _data.city!.trim().isNotEmpty &&
            _data.profilePicturePath != null;

        // "My Work" section is optional, but if any work item is selected, all must have roles
        final selectedItems = _data.selectedWorkItems ?? [];
        final bool isWorkEmpty = selectedItems.isEmpty;
        final bool isWorkComplete =
            selectedItems.isNotEmpty &&
            selectedItems.every(
              (item) => item.role != null && item.role!.isNotEmpty,
            );

        return isBasicInfoValid && (isWorkEmpty || isWorkComplete);
      case 3:
        return _data.selectedPlanId != null &&
            _data.subscriptionDuration != null;
      default:
        return true;
    }
  }

  String? getValidationError() {
    switch (_currentStep) {
      case 0:
        if (!_data.specifications.any(
          (cat) => cat.items.any((spec) => spec.isSelected),
        )) {
          return 'Please select at least one specification';
        }
        return null;
      case 1:
        if (!_data.experienceLevels.any((level) => level.isSelected)) {
          return 'Please select your experience level';
        }
        return null;
      case 2:
        if (_data.country == null || _data.country!.trim().isEmpty) {
          return 'Country is required';
        }
        if (_data.city == null || _data.city!.trim().isEmpty) {
          return 'City is required';
        }
        if (_data.profilePicturePath == null) {
          return 'Please upload your picture';
        }
        // Validate "My Work" - if any work selected, all must have roles
        final selectedItems = _data.selectedWorkItems ?? [];
        if (selectedItems.isNotEmpty) {
          final itemWithoutRole = selectedItems.where(
            (item) => item.role == null || item.role!.isEmpty,
          );
          if (itemWithoutRole.isNotEmpty) {
            return 'Please select your role for all selected works';
          }
        }
        return null;
      case 3:
        if (_data.selectedPlanId == null) {
          return 'Please select a subscription plan';
        }
        if (_data.subscriptionDuration == null) {
          return 'Please select a subscription duration';
        }
        return null;
      default:
        return null;
    }
  }

  List<String> getSelectedSpecifications() {
    return _data.specifications
        .expand((cat) => cat.items)
        .where((spec) => spec.isSelected)
        .map((spec) => spec.name)
        .toList();
  }

  String _getSelectedExperienceName() {
    try {
      final selected = _data.experienceLevels.firstWhere(
        (level) => level.isSelected,
      );
      return selected.name;
    } catch (_) {
      return '';
    }
  }

  Future<void> submitOnboarding() async {
    final currentState = state;
    if (currentState is! EnterpriseOnboardingInProgress) return;

    emit(EnterpriseOnboardingLoading());

    final selectedExperience = _getSelectedExperienceName();

    final File? profilePhoto = _data.profilePicturePath != null
        ? File(_data.profilePicturePath!)
        : null;

    final List<File>? videos = _data.videoFile != null
        ? [File(_data.videoFile!)]
        : null;

    int durationMonths = 1;
    if (_data.subscriptionDuration == SubscriptionDuration.yearly) {
      durationMonths = 12;
    } else if (_data.subscriptionDuration == SubscriptionDuration.biannual) {
      durationMonths = 6;
    }

    final selectedWorkItems = _data.selectedWorkItems ?? [];

    final selectedSpecs = getSelectedSpecifications();
    final requestModel = EnterpriseRequestModel(
      fullname: _basicData?.fullname ?? '',
      email: _basicData?.email ?? '',
      mobilePhone: _basicData?.mobilePhone ?? '',
      password: _basicData?.password ?? '',
      country: _data.country ?? '',
      city: _data.city ?? '',
      planId: _data.selectedPlanId?.toString() ?? '',
      workItemsRoles: selectedWorkItems.isNotEmpty ? selectedWorkItems : null,
      experience: selectedExperience,
      images: null,
      videos: videos,
      profilePhoto: profilePhoto,
      personalInfo: selectedSpecs.isNotEmpty
          ? jsonEncode({'specifications': selectedSpecs})
          : _data.personalInfo,
      durationMonths: durationMonths,
    );

    final result = _isSwapMode
        ? await _repository.completeEnterpriseProfile(model: requestModel)
        : await _repository.registerEnterprise(model: requestModel);

    result.fold(
      (failure) {
        emit(EnterpriseOnboardingFailure(failure.message));
        emit(
          EnterpriseOnboardingInProgress(
            currentStep: _currentStep,
            data: _data,
          ),
        );
      },
      (response) {
        String? paymentUrl;
        try {
          final dynamicResponse = response as dynamic;
          // Check if response has data and it's a map
          if (dynamicResponse.data != null) {
            final data = dynamicResponse.data as Map<String, dynamic>;

            // Try to extract payment URL
            final payment = data['payment'];
            if (payment != null && payment is Map<String, dynamic>) {
              final transaction = payment['transaction'];
              if (transaction != null && transaction is Map<String, dynamic>) {
                paymentUrl = transaction['url'] as String?;
              }
            }

            // Try to update user if user object is present in response
            // This is critical for both normal registration and swap
            try {
              UserModel? updatedUser;

              // Check if data itself looks like a user (contains id and email)
              if (data.containsKey('id') && data.containsKey('email')) {
                updatedUser = UserModel.fromJson(data);
              }
              // Check if user is nested under 'user' or 'data'
              else if (data.containsKey('user')) {
                updatedUser = UserModel.fromJson(data['user']);
              }

              if (updatedUser != null) {
                UserHelper.setUser(updatedUser);
                SecureLocalStorage.write(
                  PrefsKeys.user,
                  jsonEncode(updatedUser.toJson()),
                );
              } else if (UserHelper.userNotifier.value != null) {
                // Fallback: manually update type if we can't parse full user
                final currentUser = UserHelper.userNotifier.value!;
                final tempUser = currentUser.copyWith(type: 'enterprise');
                UserHelper.setUser(tempUser);
                SecureLocalStorage.write(
                  PrefsKeys.user,
                  jsonEncode(tempUser.toJson()),
                );
              }
            } catch (e) {
              debugPrint('Error parsing user from response: $e');
            }
          }
        } catch (e) {
          // Ignore parsing errors
        }
        emit(
          EnterpriseOnboardingSuccess(
            "Registration successful".tr(),
            paymentUrl: paymentUrl,
          ),
        );
      },
    );
  }
}
