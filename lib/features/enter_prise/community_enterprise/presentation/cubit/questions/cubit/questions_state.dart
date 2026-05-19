part of 'questions_cubit.dart';

sealed class QuestionsState extends Equatable {
  const QuestionsState();

  @override
  List<Object?> get props => [];
}

final class QuestionsInitial extends QuestionsState {}

final class QuestionsLoading extends QuestionsState {}

final class QuestionsSuccess extends QuestionsState {
  final List<QuestionResponseModel> questions;

  const QuestionsSuccess(this.questions);

  @override
  List<Object?> get props => [questions];
}

final class QuestionsFailure extends QuestionsState {
  final CustomException exception;

  const QuestionsFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class CreateQuestionLoading extends QuestionsState {}

final class CreateQuestionSuccess extends QuestionsState {
  final BaseResponseModel response;

  const CreateQuestionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

final class CreateQuestionFailure extends QuestionsState {
  final CustomException exception;

  const CreateQuestionFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class AnswersLoading extends QuestionsState {}

final class AnswersSuccess extends QuestionsState {
  final List<QuestionAnswerModel> answers;

  const AnswersSuccess(this.answers);

  @override
  List<Object?> get props => [answers];
}

final class AnswersFailure extends QuestionsState {
  final CustomException exception;

  const AnswersFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class CreateAnswerLoading extends QuestionsState {}

final class CreateAnswerSuccess extends QuestionsState {
  final QuestionAnswerModel answer;

  const CreateAnswerSuccess(this.answer);

  @override
  List<Object?> get props => [answer];
}

final class CreateAnswerFailure extends QuestionsState {
  final CustomException exception;

  const CreateAnswerFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class UpdateAnswerLoading extends QuestionsState {}

final class UpdateAnswerSuccess extends QuestionsState {
  final QuestionAnswerModel answer;

  const UpdateAnswerSuccess(this.answer);

  @override
  List<Object?> get props => [answer];
}

final class UpdateAnswerFailure extends QuestionsState {
  final CustomException exception;

  const UpdateAnswerFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class DeleteAnswerLoading extends QuestionsState {}

final class DeleteAnswerSuccess extends QuestionsState {}

final class DeleteAnswerFailure extends QuestionsState {
  final CustomException exception;

  const DeleteAnswerFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class UpdateQuestionsLoading extends QuestionsState {}

final class UpdateQuestionsSuccess extends QuestionsState {
  final BaseResponseModel questions;

  const UpdateQuestionsSuccess(this.questions);

  @override
  List<Object?> get props => [questions];
}

final class UpdateQuestionsFailure extends QuestionsState {
  final CustomException exception;

  const UpdateQuestionsFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class DeleteQuestionLoading extends QuestionsState {}

final class DeleteQuestionSuccess extends QuestionsState {
  final int questionId;

  const DeleteQuestionSuccess(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

final class DeleteQuestionFailure extends QuestionsState {
  final CustomException exception;

  const DeleteQuestionFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}

final class SpecificationsLoading extends QuestionsState {}

final class SpecificationsSuccess extends QuestionsState {
  final Map<String, List<String>> specifications;

  const SpecificationsSuccess(this.specifications);

  @override
  List<Object?> get props => [specifications];
}

final class SpecificationsFailure extends QuestionsState {
  final CustomException exception;

  const SpecificationsFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}
