class ResendSmsRequestModel {
  final String sms;

  ResendSmsRequestModel({required this.sms});

  Map<String, dynamic> toJson() {
    return {'sms': sms};
  }
}
