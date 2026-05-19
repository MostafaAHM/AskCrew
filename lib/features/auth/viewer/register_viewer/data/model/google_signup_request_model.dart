class GoogleSignupRequestModel {
  final String idToken;

  final String phone;

  GoogleSignupRequestModel({required this.idToken, required this.phone});

  Map<String, dynamic> toJson() {
    return {'id_token': idToken, 'phone': phone};
  }

  @override
  String toString() {
    return 'GoogleSignupRequestModel(idToken: ${idToken.isNotEmpty ? "***" : "empty"}, phone: $phone)';
  }
}
