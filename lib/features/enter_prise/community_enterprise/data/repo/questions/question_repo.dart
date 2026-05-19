import 'package:aflam/core/repository/repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../model/questions/request/create_answer_request_model.dart';
import '../../model/questions/request/create_question_request_model.dart';
import '../../model/questions/response/question_answer_model.dart';
import '../../model/questions/response/question_response_model.dart';

abstract class QuestionRepo extends Repository {
  Future<Either<CustomException, BaseResponseModel>> createQuestion({
    required CreateQuestionRequestModel model,
  });

  Future<Either<CustomException, List<QuestionResponseModel>>> getQuestions();

  Future<Either<CustomException, List<QuestionAnswerModel>>> getAnswers({
    required int questionId,
  });

  Future<Either<CustomException, QuestionAnswerModel>> createAnswer({
    required CreateAnswerRequestModel model,
  });

  Future<Either<CustomException, BaseResponseModel>> deleteAnswer({
    required int answerId,
  });

  Future<Either<CustomException, QuestionAnswerModel>> updateAnswer({
    required int answerId,
    required String body,
  });
  Future<Either<CustomException, BaseResponseModel>> updateQuestion({
    required int questionId,
    required CreateQuestionRequestModel model,
  });

  Future<Either<CustomException, BaseResponseModel>> deleteQuestion({
    required int questionId,
  });

  Future<Either<CustomException, Map<String, List<String>>>> getSpecifications();
}
