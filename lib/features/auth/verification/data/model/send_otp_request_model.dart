class SendOtpRequestModel {
  final String? phone;
  final String? email;

  SendOtpRequestModel({this.phone, this.email});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (phone != null && phone!.isNotEmpty) {
      // API expects mobile_phone to match signup request format
      json['mobile_phone'] = phone;
    }
    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }
    return json;
  }
}
