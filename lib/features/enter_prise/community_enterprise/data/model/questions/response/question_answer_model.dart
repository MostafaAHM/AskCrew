class QuestionAnswerModel {
  final int id;
  final int questionId;
  final String body;
  final int author;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionAnswerModel({
    required this.id,
    required this.questionId,
    required this.body,
    required this.author,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerModel(
      id: json['id'] as int,
      questionId: json['question'] as int,
      body: json['body'] as String,
      author: json['author'] as int,
      authorName: json['author_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
