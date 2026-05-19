import 'package:dio/dio.dart';

class CreateQuestionRequestModel {
  final String title;
  final String body;
  final String specification;

  const CreateQuestionRequestModel({
    required this.title,
    required this.body,
    required this.specification,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'specification': specification};
  }

  FormData toFormData() {
    return FormData.fromMap(toJson());
  }
}
