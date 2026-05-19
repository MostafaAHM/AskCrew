import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/repository/enterprise_repository.dart';
import '../../../data/repository/student_profile_repository.dart';
import 'student_edit_profile_state.dart';

class StudentEditProfileCubit extends Cubit<StudentEditProfileState> {
  final StudentProfileRepository profileRepository;
  final EnterpriseRepository enterpriseRepository;

  StudentEditProfileCubit({
    required this.profileRepository,
    required this.enterpriseRepository,
  }) : super(StudentEditProfileInitial());

  File? selectedProfilePhoto;
  bool? isAvailable;
  List<SelectedWorkItem> selectedWorkItems = [];
  List<SelectedWorkItem> originalWorkItems = [];
  List<ContentCatalogItem> searchResults = [];
  List<int> deletedRoleIds = [];

  void _emitWorksLoaded({bool isSearching = false}) {
    emit(
      StudentEditProfileWorksLoaded(
        searchResults: List<ContentCatalogItem>.from(searchResults),
        selectedWorkItems: List<SelectedWorkItem>.from(selectedWorkItems),
        isSearching: isSearching,
      ),
    );
  }

  void init(UserModel currentUser) {
    print('=== StudentEditProfileCubit - init ===');
    print('Current user: ${currentUser.id}');
    print('Profile available: ${currentUser.profile?.isAvailable}');
    print('Profile roles: ${currentUser.profile?.roles}');

    if (currentUser.profile?.isAvailable != null) {
      isAvailable = currentUser.profile!.isAvailable;
    } else {
      isAvailable = false;
    }

    // Load existing roles from profile
    if (currentUser.profile?.roles != null) {
      final rolesList = currentUser.profile!.roles as List;
      print('Roles list length: ${rolesList.length}');

      selectedWorkItems = rolesList.map((e) {
        print('Processing role item: $e');
        final m = Map<String, dynamic>.from(e as Map);
        print('Map: $m');

        final content = m['content'] != null
            ? Map<String, dynamic>.from(m['content'] as Map)
            : <String, dynamic>{};
        print('Content: $content');

        final rawId = content['id'] ?? m['content_id'];
        final int parsedId;

        if (rawId is int) {
          parsedId = rawId;
        } else if (rawId is String) {
          parsedId = int.tryParse(rawId) ?? 0;
        } else {
          parsedId = 0;
        }

        final item = SelectedWorkItem(
          id: parsedId,
          type: content['type'] ?? m['content_type'] ?? '',
          name: content['name'] ?? m['name'] ?? '',
          poster: content['poster'] ?? content['image'] ?? m['image'],
          role: m['role'] ?? '',
          roleId: m['id'] is int ? m['id'] : int.tryParse(m['id'].toString()),
          isExisting: true,
        );

        print(
          'Created SelectedWorkItem: id=${item.id}, type=${item.type}, roleId=${item.roleId}',
        );
        return item;
      }).toList();

      originalWorkItems = List.from(selectedWorkItems);
      print('Original work items set: ${originalWorkItems.length} items');
    } else {
      print('No roles found in profile');
    }

    _emitWorksLoaded();
  }

  void pickImage(File file) {
    selectedProfilePhoto = file;
    emit(StudentEditProfilePhotoSelected(file));
  }

  void toggleAvailable(bool value) {
    isAvailable = value;
    emit(StudentEditProfileInitial());
  }

  Future<void> searchContentCatalog(String query, {String? type}) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      _emitWorksLoaded();
      return;
    }

    _emitWorksLoaded(isSearching: true);

    final result = await enterpriseRepository.searchContentCatalog(
      query,
      type: type,
    );
    result.fold(
      (failure) {
        searchResults = [];
        _emitWorksLoaded();
      },
      (items) {
        searchResults = List<ContentCatalogItem>.from(items);
        _emitWorksLoaded();
      },
    );
  }

  void addSelectedWorkItem(ContentCatalogItem item) {
    if (selectedWorkItems.any((e) => e.id == item.id && e.type == item.type)) {
      return;
    }
    selectedWorkItems = [
      ...selectedWorkItems,
      SelectedWorkItem(
        id: item.id,
        type: item.type,
        name: item.name,
        poster: item.poster,
        isExisting: false,
      ),
    ];
    // Remove from search results to avoid duplicate display
    searchResults = searchResults
        .where((e) => !(e.id == item.id && e.type == item.type))
        .toList();
    _emitWorksLoaded();
  }

  void removeSelectedWorkItem(int id, String type) {
    print('=== removeSelectedWorkItem ===');
    print('Removing: id=$id, type=$type');

    // Find the item to get its roleId
    final itemToRemove = selectedWorkItems.firstWhere(
      (item) => item.id == id && item.type == type,
      orElse: () => SelectedWorkItem(id: id, type: type, name: ''),
    );

    print(
      'Item to remove: ${itemToRemove.id}-${itemToRemove.type}, roleId=${itemToRemove.roleId}',
    );

    // If it's an existing item with roleId, add to deleted list for later
    if (itemToRemove.isExisting && itemToRemove.roleId != null) {
      print('📝 Adding roleId=${itemToRemove.roleId} to deleted list');
      deletedRoleIds.add(itemToRemove.roleId!);
    }

    // Remove from local lists
    selectedWorkItems = selectedWorkItems
        .where((item) => !(item.id == id && item.type == type))
        .toList();

    print('Updated selectedWorkItems count: ${selectedWorkItems.length}');
    print('Deleted role IDs: $deletedRoleIds');

    _emitWorksLoaded();
  }

  void updateWorkItemRole(int id, String type, String role) {
    final index = selectedWorkItems.indexWhere(
      (e) => e.id == id && e.type == type,
    );
    if (index != -1) {
      final updatedItems = List<SelectedWorkItem>.from(selectedWorkItems);
      updatedItems[index] = updatedItems[index].copyWith(role: role);
      selectedWorkItems = updatedItems;
      _emitWorksLoaded();
    }
  }

  void clearSearchResults() {
    searchResults = [];
    _emitWorksLoaded();
  }

  Future<void> updateProfile({
    required String fullname,
    String? personalInfo,
  }) async {
    emit(StudentEditProfileLoading());

    print('=== StudentEditProfileCubit - updateProfile ===');
    print('Selected work items count: ${selectedWorkItems.length}');
    print('Roles to delete count: ${deletedRoleIds.length}');

    // First delete the roles marked for deletion
    for (final roleId in deletedRoleIds) {
      print('🗑️ Deleting roleId: $roleId');
      final deleteResult = await enterpriseRepository.deleteUserRole(
        roleId: roleId,
      );
      deleteResult.fold(
        (failure) =>
            print('❌ Failed to delete roleId $roleId: ${failure.message}'),
        (_) => print('✅ RoleId $roleId deleted successfully'),
      );
    }
    deletedRoleIds.clear();

    // Then update basic profile
    final result = await profileRepository.updateProfile(
      fullname: fullname,
      profilePhoto: selectedProfilePhoto,
      personalInfo: personalInfo,
      isAvailable: isAvailable ?? false,
    );

    result.fold(
      (failure) {
        print('❌ Basic profile update failed: ${failure.message}');
        emit(StudentEditProfileFailure(failure.message));
      },
      (user) async {
        print('✅ Basic profile updated successfully');

        // Add new roles
        final rolesToAdd = selectedWorkItems.where(
          (newItem) => !newItem.isExisting,
        );

        print('Roles to add count: ${rolesToAdd.length}');

        for (final item in rolesToAdd) {
          print('➕ Adding role: ${item.id}-${item.type}, role: ${item.role}');
          if (item.role != null && item.role!.isNotEmpty) {
            final addResult = await enterpriseRepository.addUserRole(
              contentId: item.id,
              role: item.role!,
            );
            addResult.fold(
              (failure) => print('❌ Failed to add role: ${failure.message}'),
              (_) => print('✅ Role added successfully'),
            );
          } else {
            print('⚠️ No role selected for this item, skipping add');
          }
        }

        print('✅ Profile update complete!');
        emit(StudentEditProfileSuccess(user));
      },
    );
  }
}
