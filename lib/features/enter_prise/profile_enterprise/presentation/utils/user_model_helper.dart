import 'package:aflam/features/auth/login/data/model/response/profile_model.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';

class UserModelHelper {
  /// Create a UserModel from partial data (for navigation purposes)
  static UserModel createFromPartialData({
    required int id,
    String? fullname,
    String? email,
    String? profilePhoto,
    String? specification,
  }) {
    return UserModel(
      id: id,
      email: email ?? '',
      fullname: fullname ?? 'User $id',
      mobilePhone: '',
      wallet: '0.00',
      points: 0,
      profilePhoto: profilePhoto,
      personalInfo: null,
      isVerified: false,
      isActive: true,
      type: '',
      typeInt: 0,
      dateJoined: DateTime.now(),
      profile: specification != null
          ? ProfileModel(
              favoriteCategories: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              specification: specification,
            )
          : null,
    );
  }
}

