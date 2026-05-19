
import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_movie_request_model.dart';
import '../models/response/create_movie_response_model.dart';
import 'update_movie_repository.dart';

class UpdateMovieRepositoryImpl extends Repository implements UpdateMovieRepository {
  @override
  Future<Either<CustomException, CreateMovieResponseModel>> updateMovie({
    required UpdateMovieRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateMovieResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.updateMovie(model.movieId),
            method: RequestMethod.patch, // Using PATCH
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
