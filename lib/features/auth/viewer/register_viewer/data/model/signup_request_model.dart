class SignupRequestModel {
  final String fullname;
  final String email;
  final String mobilePhone;
  final String password;

  SignupRequestModel({
    required this.fullname,
    required this.email,
    required this.mobilePhone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'mobile_phone': mobilePhone,
      'password': password,
    };
  }
}
