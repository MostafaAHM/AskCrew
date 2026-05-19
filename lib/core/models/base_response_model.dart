class BaseResponseModel {
  BaseResponseModel({required this.code, required this.message, this.data});

  final int? code;
  final String? message;
  final dynamic data;

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    // Try to get message from different possible locations
    String? message;

    // First, check if message exists directly in json
    if (json.containsKey('message') && json['message'] != null) {
      message = json['message'].toString();
    }
    // Check in additionalProp1
    else if (json.containsKey('additionalProp1') &&
        (json['additionalProp1'] is Map<String, dynamic> &&
            json['additionalProp1'].containsKey('message'))) {
      message = json['additionalProp1']['message'].toString();
    }
    // Check in response object
    else if (json['response'] is Map<String, dynamic> &&
        (json['response'] as Map<String, dynamic>).containsKey('message')) {
      message = json['response']['message'].toString();
    }
    // Fallback to response.toString()
    else if (json.containsKey('response')) {
      message = json['response'].toString();
    }

    return BaseResponseModel(code: json['code'], message: message, data: json);
  }
  factory BaseResponseModel.fromEJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      code: json['code'],
      message: json['error']['message'],
      data: json,
    );
  }
}

/*class BaseResponseModel<T> {
  final int code;
  final String? message;
  final T? response;

  BaseResponseModel({required this.code, required this.response, this.message});

  factory BaseResponseModel.fromJson(Map<String, dynamic> json,
      {T Function(Map<String, dynamic>)? fromJsonT}) {
    return BaseResponseModel(
      code: json['code'],
      message: json.containsKey('additionalProp1') &&
              (json['additionalProp1'] is Map<String, dynamic> &&
                  json['additionalProp1'].containsKey('message'))
          ? json['additionalProp1']['message']
          : "",
      response: json.containsKey('response') &&
              json['response'] is Map<String, dynamic> &&
              fromJsonT != null
          ? fromJsonT(json['response'])
          : null,
    );
  }
}*/
