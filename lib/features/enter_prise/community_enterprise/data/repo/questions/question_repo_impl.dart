import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../../../../../core/network/network_request.dart';
import '../../model/questions/request/create_answer_request_model.dart';
import '../../model/questions/request/create_question_request_model.dart';
import '../../model/questions/response/question_answer_model.dart';
import '../../model/questions/response/question_response_model.dart';
import 'question_repo.dart';

class QuestionRepoImpl extends QuestionRepo {
  @override
  Future<Either<CustomException, BaseResponseModel>> createQuestion({
    required CreateQuestionRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.communityQuestions,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: model.toFormData(),
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, List<QuestionResponseModel>>>
  getQuestions() async {
    final result = await exceptionHandler(() async {
      final questions = await dioService.callApi(
        NetworkRequest(
          AppUrls.getQuestions,
          method: RequestMethod.get,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          final map = json as Map<String, dynamic>;
          final results = map['results'] as List<dynamic>;

          return results
              .map(
                (e) =>
                    QuestionResponseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        },
      );

      return questions;
    });

    return result;
  }

  @override
  Future<Either<CustomException, List<QuestionAnswerModel>>> getAnswers({
    required int questionId,
  }) async {
    final result = await exceptionHandler(() async {
      final answers = await dioService.callApi(
        NetworkRequest(
          AppUrls.getAnswers(questionId.toString()),
          method: RequestMethod.get,
          requestWithOutToken: false,
          queryParameters: {'question': questionId},
        ),
        mapper: (json) {
          final map = json as Map<String, dynamic>;
          final results = map['results'] as List<dynamic>;

          return results
              .map(
                (e) => QuestionAnswerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        },
      );

      return answers;
    });

    return result;
  }

  @override
  Future<Either<CustomException, QuestionAnswerModel>> createAnswer({
    required CreateAnswerRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.createAnswers,
          method: RequestMethod.post,
          requestWithOutToken: false,
          body: model.toJson(),
        ),
        mapper: (json) =>
            QuestionAnswerModel.fromJson(json as Map<String, dynamic>),
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> deleteAnswer({
    required int answerId,
  }) async {
    final result = await exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.deleteAnswer(answerId),
          method: RequestMethod.delete,
          requestWithOutToken: false,
        ),
        mapper: (json) =>
            BaseResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return BaseResponseModel(
        message: 'community_answer_delete_success'.tr(),
        code: 204,
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, QuestionAnswerModel>> updateAnswer({
    required int answerId,
    required String body,
  }) async {
    final result = await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.updateAnswer(answerId),
          method: RequestMethod.patch,
          requestWithOutToken: false,
          body: {'body': body},
        ),
        mapper: (json) =>
            QuestionAnswerModel.fromJson(json as Map<String, dynamic>),
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> updateQuestion({
    required int questionId,
    required CreateQuestionRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      return await dioService.callApi(
        NetworkRequest(
          AppUrls.updateQuestion(questionId),
          method: RequestMethod.patch,
          requestWithOutToken: false,
          isFormData: true,
          formDataBody: model.toFormData(),
        ),
        mapper: (json) =>
            BaseResponseModel.fromJson(json as Map<String, dynamic>),
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> deleteQuestion({
    required int questionId,
  }) async {
    final result = await exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.deleteQuestion(questionId),
          method: RequestMethod.delete,
          requestWithOutToken: false,
        ),
        mapper: (json) =>
            BaseResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return BaseResponseModel(
        message: 'community_answer_delete_success'.tr(),
        code: 204,
      );
    });

    return result;
  }

  @override
  Future<Either<CustomException, Map<String, List<String>>>>
  getSpecifications() async {
    final result = await exceptionHandler(() async {
      final jsonResponse = await dioService.callApi(
        NetworkRequest(AppUrls.specifications, method: RequestMethod.get),
        mapper: (json) => json,
      );

      // Extract the map from the response
      Map<String, dynamic> data = jsonResponse;
      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('data')) {
          data = jsonResponse['data'] as Map<String, dynamic>;
        } else if (jsonResponse.containsKey('response')) {
          data = jsonResponse['response'] as Map<String, dynamic>;
        }
      }

      final Map<String, List<String>> specifications = {};
      data.forEach((key, value) {
        if (value is List) {
          specifications[key] = value.map((e) => e.toString()).toList();
        }
      });

      return specifications;
    });
    return result;
  }
}
