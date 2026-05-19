import '../../../../../../core/models/base_response_model.dart';
import 'user_model.dart';

class LoginResponseModel extends BaseResponseModel {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  LoginResponseModel({
    required super.code,
    required super.message,
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponseModel.fromJson({required Map<String, dynamic> json}) {
    final tokens = json['tokens'] ?? {};

    final tokenType = tokens['token_type'] ?? tokens['type'] ?? "Bearer";

    return LoginResponseModel(
      code: json['code'] ?? 200,
      message: json['message'] ?? '',
      accessToken: tokens['access'] ?? '',
      tokenType: tokenType,
      user: UserModel.fromJson(json['user']),
    );
  }
}
