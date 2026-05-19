import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_movie_request_model.dart';
import '../models/response/create_movie_response_model.dart';
import 'create_movie_repository.dart';

class CreateMovieRepositoryImpl extends Repository implements CreateMovieRepository {
  @override
  Future<Either<CustomException, CreateMovieResponseModel>> createMovie({
    required CreateMovieRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateMovieResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.addWork,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => CreateMovieResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }
}
