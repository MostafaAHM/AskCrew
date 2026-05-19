import 'package:dio/dio.dart';

class WalletAddOptions {
  final double amount;
  final String? name;
  final bool? usePoints;

  WalletAddOptions({required this.amount, this.name, this.usePoints});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'amount': amount.toString()};

    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }

    if (usePoints != null && usePoints == true) {
      json['use_points'] = "1";
    }

    return json;
  }

  FormData toFormData() {
    return FormData.fromMap(toJson());
  }
}
