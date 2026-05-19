class ResetPasswordRequestModel {
  final String newPassword;
  final String code;

  ResetPasswordRequestModel({required this.newPassword, required this.code});

  Map<String, dynamic> toJson() {
    return {'new_password': newPassword, 'code': code};
  }
}
