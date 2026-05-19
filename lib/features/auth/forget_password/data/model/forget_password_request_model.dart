class ForgetPasswordRequestModel {
  final String? email;
  final String? phone;

  ForgetPasswordRequestModel({this.email, this.phone});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }
    if (phone != null && phone!.isNotEmpty) {
      json['mobile_phone'] = phone;
    }
    return json;
  }
}
