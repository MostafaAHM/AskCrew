import '../../../../../../../core/enums/subscription_duration.dart';
import 'specification_model.dart';
import 'experience_level_model.dart';

class EnterpriseOnboardingData {
  final List<SpecificationCategoryModel> specifications;
  final List<ExperienceLevelModel> experienceLevels;
  final String? personalInfo;
  final String? country;
  final String? city;
  final String? profilePicturePath;
  final String? selectedWork;
  final int? selectedPlanId;
  final SubscriptionDuration? subscriptionDuration;
  final int? durationMonths;
  final String? videoFile;
  final String? videoId;
  final List<String>? portfolioLinks;
  final String? contentType;
  final String? objectId;
  final List<WorkItem>? selectableWorks;
  final String? selectedRole;
  final List<SelectedWorkItem>? selectedWorkItems;
  final List<ContentCatalogItem>? searchResults;

  EnterpriseOnboardingData({
    this.specifications = const [],
    this.experienceLevels = const [],
    this.personalInfo,
    this.country,
    this.city,
    this.profilePicturePath,
    this.selectedWork,
    this.selectedPlanId,
    this.subscriptionDuration,
    this.durationMonths,
    this.videoFile,
    this.videoId,
    this.portfolioLinks,
    this.contentType,
    this.objectId,
    this.selectableWorks,
    this.selectedRole,
    this.selectedWorkItems,
    this.searchResults,
  });

  EnterpriseOnboardingData copyWith({
    List<SpecificationCategoryModel>? specifications,
    List<ExperienceLevelModel>? experienceLevels,
    String? personalInfo,
    String? country,
    String? city,
    String? profilePicturePath,
    String? selectedWork,
    int? selectedPlanId,
    SubscriptionDuration? subscriptionDuration,
    int? durationMonths,
    String? videoFile,
    String? videoId,
    List<String>? portfolioLinks,
    String? contentType,
    String? objectId,
    List<WorkItem>? selectableWorks,
    String? selectedRole,
    List<SelectedWorkItem>? selectedWorkItems,
    List<ContentCatalogItem>? searchResults,
  }) {
    return EnterpriseOnboardingData(
      specifications: specifications ?? this.specifications,
      experienceLevels: experienceLevels ?? this.experienceLevels,
      personalInfo: personalInfo ?? this.personalInfo,
      country: country ?? this.country,
      city: city ?? this.city,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      selectedWork: selectedWork ?? this.selectedWork,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      subscriptionDuration: subscriptionDuration ?? this.subscriptionDuration,
      durationMonths: durationMonths ?? this.durationMonths,
      videoFile: videoFile ?? this.videoFile,
      videoId: videoId ?? this.videoId,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      contentType: contentType ?? this.contentType,
      objectId: objectId ?? this.objectId,
      selectableWorks: selectableWorks ?? this.selectableWorks,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedWorkItems: selectedWorkItems ?? this.selectedWorkItems,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specifications': specifications.map((s) => s.toJson()).toList(),
      'experienceLevels': experienceLevels.map((e) => e.toJson()).toList(),
      'personalInfo': personalInfo,
      'country': country,
      'city': city,
      'profilePicturePath': profilePicturePath,
      'selectedWork': selectedWork,
      'selectedPlanId': selectedPlanId,
      'subscriptionDuration': subscriptionDuration?.name,
      'portfolioLinks': portfolioLinks,
      'contentType': contentType,
      'objectId': objectId,
      'selectedRole': selectedRole,
    };
  }

  factory EnterpriseOnboardingData.fromJson(Map<String, dynamic> json) {
    return EnterpriseOnboardingData(
      specifications:
          (json['specifications'] as List?)
              ?.map((s) => SpecificationCategoryModel.fromJson(s))
              .toList() ??
          [],
      experienceLevels:
          (json['experienceLevels'] as List?)
              ?.map((e) => ExperienceLevelModel.fromJson(e))
              .toList() ??
          [],
      personalInfo: json['personalInfo'],
      country: json['country'],
      city: json['city'],
      profilePicturePath: json['profilePicturePath'],
      selectedWork: json['selectedWork'],
      selectedPlanId: json['selectedPlanId'] != null
          ? int.tryParse(json['selectedPlanId'].toString())
          : null,
      subscriptionDuration: json['subscriptionDuration'] != null
          ? SubscriptionDuration.values.firstWhere(
              (e) => e.name == json['subscriptionDuration'],
              orElse: () => SubscriptionDuration.monthly,
            )
          : null,
      portfolioLinks: (json['portfolioLinks'] as List?)?.cast<String>(),
      contentType: json['contentType'],
      objectId: json['objectId'],
      selectedRole: json['selectedRole'],
    );
  }
}

class WorkItem {
  final String id;
  final String name;
  final String? posterPath;

  WorkItem({required this.id, required this.name, this.posterPath});

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
    );
  }
}

class ContentCatalogItem {
  final int id;
  final String type;
  final String name;
  final String? poster;

  ContentCatalogItem({
    required this.id,
    required this.type,
    required this.name,
    this.poster,
  });

  factory ContentCatalogItem.fromJson(Map<String, dynamic> json) {
    return ContentCatalogItem(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      poster: json['poster'],
    );
  }
}

class SelectedWorkItem {
  final int id;
  final String type;
  final String name;
  final String? poster;
  final String? role;
  final int? roleId;
  final bool isExisting;

  SelectedWorkItem({
    required this.id,
    required this.type,
    required this.name,
    this.poster,
    this.role,
    this.roleId,
    this.isExisting = false,
  });

  SelectedWorkItem copyWith({
    String? role,
    int? roleId,
    bool? isExisting,
  }) {
    return SelectedWorkItem(
      id: id,
      type: type,
      name: name,
      poster: poster,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      isExisting: isExisting ?? this.isExisting,
    );
  }

  Map<String, dynamic> toRoleMap() {
    return {'content_type': type, 'content_id': id, 'role': role};
  }
}
