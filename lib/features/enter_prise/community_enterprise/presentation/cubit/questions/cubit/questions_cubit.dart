import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../../core/error/exceptions.dart' show CustomException;
import '../../../../../../../core/models/base_response_model.dart';
import '../../../../data/model/questions/request/create_answer_request_model.dart';
import '../../../../data/model/questions/request/create_question_request_model.dart';
import '../../../../data/model/questions/response/question_answer_model.dart';
import '../../../../data/model/questions/response/question_response_model.dart';
import '../../../../data/repo/questions/question_repo.dart';

part 'questions_state.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  final QuestionRepo repo;

  QuestionsCubit(this.repo) : super(QuestionsInitial());

  Future<void> getQuestions() async {
    emit(QuestionsLoading());
    final result = await repo.getQuestions();
    result.fold(
      (exception) => emit(QuestionsFailure(exception)),
      (questions) => emit(QuestionsSuccess(questions)),
    );
  }

  Future<void> createQuestion({
    required CreateQuestionRequestModel model,
  }) async {
    emit(CreateQuestionLoading());
    final result = await repo.createQuestion(model: model);
    result.fold(
      (exception) => emit(CreateQuestionFailure(exception)),
      (response) => emit(CreateQuestionSuccess(response)),
    );
  }

  Future<void> getAnswers(int questionId) async {
    emit(AnswersLoading());
    final result = await repo.getAnswers(questionId: questionId);
    result.fold(
      (exception) => emit(AnswersFailure(exception)),
      (answers) => emit(AnswersSuccess(answers)),
    );
  }

  Future<void> createAnswer({required CreateAnswerRequestModel model}) async {
    emit(CreateAnswerLoading());
    final result = await repo.createAnswer(model: model);
    result.fold(
      (exception) => emit(CreateAnswerFailure(exception)),
      (answer) => emit(CreateAnswerSuccess(answer)),
    );
  }

  Future<void> updateAnswer({
    required int answerId,
    required String body,
  }) async {
    emit(UpdateAnswerLoading());
    final result = await repo.updateAnswer(answerId: answerId, body: body);
    result.fold(
      (exception) => emit(UpdateAnswerFailure(exception)),
      (answer) => emit(UpdateAnswerSuccess(answer)),
    );
  }

  Future<void> deleteAnswer({required int answerId}) async {
    emit(DeleteAnswerLoading());
    final result = await repo.deleteAnswer(answerId: answerId);
    result.fold(
      (exception) => emit(DeleteAnswerFailure(exception)),
      (_) => emit(DeleteAnswerSuccess()),
    );
  }

  updateQuestion({
    required int questionId,
    required CreateQuestionRequestModel model,
  }) async {
    emit(UpdateQuestionsLoading());

    final result = await repo.updateQuestion(
      questionId: questionId,
      model: model,
    );

    result.fold(
      (e) => emit(UpdateQuestionsFailure(e)),
      (r) => emit(UpdateQuestionsSuccess(r)),
    );
  }

  Future<void> deleteQuestion({required int questionId}) async {
    // Remove question from current state immediately (optimistic update)
    final currentState = state;
    if (currentState is QuestionsSuccess) {
      final updatedQuestions = currentState.questions
          .where((q) => q.id != questionId)
          .toList();
      emit(QuestionsSuccess(updatedQuestions));
    }

    final result = await repo.deleteQuestion(questionId: questionId);
    result.fold((exception) {
      // On failure, revert to original state
      if (currentState is QuestionsSuccess) {
        emit(currentState);
      }
      emit(DeleteQuestionFailure(exception));
    }, (_) => emit(DeleteQuestionSuccess(questionId)));
    // getQuestions();
  }

  Future<void> getSpecifications() async {
    emit(SpecificationsLoading());
    final result = await repo.getSpecifications();
    result.fold(
      (exception) => emit(SpecificationsFailure(exception)),
      (specifications) => emit(SpecificationsSuccess(specifications)),
    );
  }
}
