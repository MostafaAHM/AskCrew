class GoogleLoginRequestModel {
  final String idToken;

  GoogleLoginRequestModel({required this.idToken});

  Map<String, dynamic> toJson() {
    return {'id_token': idToken};
  }

  @override
  String toString() {
    return 'GoogleLoginRequestModel(idToken: ${idToken.isNotEmpty ? "***" : "empty"})';
  }
}
