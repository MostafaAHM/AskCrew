import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../auth/login/data/model/response/user_model.dart';
import '../../data/repository/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  UserModel? _currentUser;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  UserModel? get currentUser => _currentUser;

  /// Helper method to safely emit states (checks if cubit is closed)
  void _safeEmit(ProfileState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Determines if the authenticated user owns the profile being viewed
  bool _isOwner(UserModel profileUser) {
    final authUser = UserHelper.userNotifier.value;
    if (authUser == null) return false;
    return authUser.id.toString() == profileUser.id.toString();
  }

  Future<void> getUserProfile(int userId) async {
    if (isClosed) return;
    _safeEmit(ProfileLoading(previousUser: _currentUser));

    final result = await _repository.getUserProfile(userId: userId);

    if (isClosed) return;

    result.fold((error) => _safeEmit(ProfileError(error.toString())), (user) {
      _currentUser = user;
      final isOwner = _isOwner(user);
      _safeEmit(ProfileLoaded(user: user, isOwner: isOwner));
    });
  }

  Future<void> getMyProfile() async {
    if (isClosed) return;
    _safeEmit(ProfileLoading(previousUser: _currentUser));

    final result = await _repository.getMyProfile();

    if (isClosed) return;

    result.fold((error) => _safeEmit(ProfileError(error.toString())), (user) {
      _currentUser = user;
      // Update UserHelper with fresh profile data
      UserHelper.setUser(user);
      // When getting own profile, isOwner is always true
      _safeEmit(ProfileLoaded(user: user, isOwner: true));
    });
  }

  /// Refresh the current profile data
  Future<void> refresh() async {
    if (_currentUser != null) {
      await getUserProfile(_currentUser!.id);
    }
  }

  /// Seeding the profile with existing user data (e.g. from optimistic updates)
  void seedProfile(UserModel user, {bool? isOwner}) {
    if (isClosed) return;
    _currentUser = user;
    final ownerStatus = isOwner ?? _isOwner(user);
    _safeEmit(ProfileLoaded(user: user, isOwner: ownerStatus));
  }
}
