class CreateAnswerRequestModel {
  final int question;
  final String body;

  const CreateAnswerRequestModel({required this.question, required this.body});

  Map<String, dynamic> toJson() {
    return {'question': question, 'body': body};
  }
}
