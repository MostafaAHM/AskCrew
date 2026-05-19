import 'package:aflam/core/enums/subscription_duration.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import 'academic_year_model.dart';
import 'institute_model.dart';
import 'student_specification_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/experience_level_model.dart';

class StudentOnboardingData {
  final List<InstituteModel> institutes;
  final List<SpecificationCategoryModel> specifications;
  final List<AcademicYearModel> academicYears;
  final String? graduatedYear;
  final String? selectedWork;
  final String? country;
  final String? city;
  final String? profilePicturePath;
  final String? cvPath;
  final String? personalInfo;
  final String? facebookLink;
  final String? instagramLink;
  final String? linkedinLink;
  final String? youtubeLink;
  final String? emailAddress;
  final List<ExperienceLevelModel> experienceLevels;
  final List<String> portfolioLinks;

  final String? contentType;
  final String? objectId;
  final List<WorkItem>? selectableWorks;
  final String? selectedRole;
  final List<SelectedWorkItem>? selectedWorkItems;
  final List<ContentCatalogItem>? searchResults;
  final String? videoFile;
  final String? videoId;
  final int? selectedPlanId;
  final SubscriptionDuration? subscriptionDuration;

  StudentOnboardingData({
    this.institutes = const [],
    this.specifications = const [],
    this.academicYears = const [],
    this.graduatedYear,
    this.selectedWork,
    this.country,
    this.city,
    this.profilePicturePath,
    this.cvPath,
    this.personalInfo,
    this.facebookLink,
    this.instagramLink,
    this.linkedinLink,
    this.youtubeLink,
    this.emailAddress,
    this.contentType,
    this.objectId,
    this.selectableWorks,
    this.selectedRole,
    this.selectedWorkItems,
    this.searchResults,
    this.videoFile,
    this.videoId,
    this.selectedPlanId,
    this.subscriptionDuration,
    this.experienceLevels = const [],
    this.portfolioLinks = const [],
  });

  StudentOnboardingData copyWith({
    List<InstituteModel>? institutes,
    List<SpecificationCategoryModel>? specifications,
    List<AcademicYearModel>? academicYears,
    String? graduatedYear,
    String? selectedWork,
    String? country,
    String? city,
    String? profilePicturePath,
    String? cvPath,
    String? personalInfo,
    String? facebookLink,
    String? instagramLink,
    String? linkedinLink,
    String? youtubeLink,
    String? emailAddress,
    String? contentType,
    String? objectId,
    List<WorkItem>? selectableWorks,
    String? selectedRole,
    List<SelectedWorkItem>? selectedWorkItems,
    List<ContentCatalogItem>? searchResults,
    String? videoFile,
    String? videoId,
    int? selectedPlanId,
    SubscriptionDuration? subscriptionDuration,
    List<ExperienceLevelModel>? experienceLevels,
    List<String>? portfolioLinks,
  }) {
    return StudentOnboardingData(
      institutes: institutes ?? this.institutes,
      specifications: specifications ?? this.specifications,
      academicYears: academicYears ?? this.academicYears,
      graduatedYear: graduatedYear ?? this.graduatedYear,
      selectedWork: selectedWork ?? this.selectedWork,
      country: country ?? this.country,
      city: city ?? this.city,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      cvPath: cvPath ?? this.cvPath,
      personalInfo: personalInfo ?? this.personalInfo,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      linkedinLink: linkedinLink ?? this.linkedinLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      emailAddress: emailAddress ?? this.emailAddress,
      contentType: contentType ?? this.contentType,
      objectId: objectId ?? this.objectId,
      selectableWorks: selectableWorks ?? this.selectableWorks,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedWorkItems: selectedWorkItems ?? this.selectedWorkItems,
      searchResults: searchResults ?? this.searchResults,
      videoFile: videoFile ?? this.videoFile,
      videoId: videoId ?? this.videoId,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      subscriptionDuration: subscriptionDuration ?? this.subscriptionDuration,
      experienceLevels: experienceLevels ?? this.experienceLevels,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institutes': institutes.map((i) => i.toJson()).toList(),
      'specifications': specifications.map((s) => s.toJson()).toList(),
      'academicYears': academicYears.map((a) => a.toJson()).toList(),
      'graduatedYear': graduatedYear,
      'selectedWork': selectedWork,
      'country': country,
      'city': city,
      'profilePicturePath': profilePicturePath,
      'cvPath': cvPath,
      'personalInfo': personalInfo,
      'facebookLink': facebookLink,
      'instagramLink': instagramLink,
      'linkedinLink': linkedinLink,
      'youtubeLink': youtubeLink,
      'emailAddress': emailAddress,
      'contentType': contentType,
      'objectId': objectId,
      'selectedRole': selectedRole,
      'videoFile': videoFile,
      'videoId': videoId,
      'selectedPlanId': selectedPlanId,
      'subscriptionDuration': subscriptionDuration?.name,
    };
  }

  factory StudentOnboardingData.fromJson(Map<String, dynamic> json) {
    return StudentOnboardingData(
      institutes:
          (json['institutes'] as List?)
              ?.map((i) => InstituteModel.fromJson(i))
              .toList() ??
          [],
      specifications:
          (json['specifications'] as List?)
              ?.map((s) => SpecificationCategoryModel.fromJson(s))
              .toList() ??
          [],
      academicYears:
          (json['academicYears'] as List?)
              ?.map((a) => AcademicYearModel.fromJson(a))
              .toList() ??
          [],
      graduatedYear: json['graduatedYear'],
      selectedWork: json['selectedWork'],
      country: json['country'],
      city: json['city'],
      profilePicturePath: json['profilePicturePath'],
      cvPath: json['cvPath'],
      personalInfo: json['personalInfo'],
      facebookLink: json['facebookLink'],
      instagramLink: json['instagramLink'],
      linkedinLink: json['linkedinLink'],
      youtubeLink: json['youtubeLink'],
      emailAddress: json['emailAddress'],
      contentType: json['contentType'],
      objectId: json['objectId'],
      selectedRole: json['selectedRole'],
      videoFile: json['videoFile'],
      videoId: json['videoId'],
      selectedPlanId: json['selectedPlanId'],
      subscriptionDuration: json['subscriptionDuration'] != null
          ? SubscriptionDuration.values.firstWhere(
              (e) => e.name == json['subscriptionDuration'],
              orElse: () => SubscriptionDuration.monthly,
            )
          : null,
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
