import 'question_answer_model.dart';

class QuestionResponseModel {
  final int id;
  final String title;
  final String specification;
  final String body;
  final int author;
  final String authorName;
  final String authorSpecification;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionAnswerModel> answers;
  const QuestionResponseModel({
    required this.id,
    required this.title,
    required this.specification,
    required this.body,
    required this.author,
    required this.authorName,
    required this.authorSpecification,
    required this.createdAt,
    required this.updatedAt,
    required this.answers,
  });
  factory QuestionResponseModel.fromJson(Map<String, dynamic> json) {
    return QuestionResponseModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      body: json['body'] as String? ?? '',
      author: json['author'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? 'Unknown',
      authorSpecification: json['author_specification'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => QuestionAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
