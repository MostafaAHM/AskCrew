
import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import 'delete_movie_repository.dart';

class DeleteMovieRepositoryImpl extends Repository implements DeleteMovieRepository {
  @override
  Future<Either<CustomException, String>> deleteMovie(int id) {
    return exceptionHandler(
      () async {
        final result = await dioService.callApi(
          NetworkRequest(
            AppUrls.deleteMovie(id),
            method: RequestMethod.delete,
          ),
        );
        // Assuming result might be a message map or empty string.
        // My previous fix in dio_service returns data as is if no mapper.
        // Or I can use a mapper to ensure String.
        // If result is Map, extract message.
        if (result is Map && result.containsKey('message')) {
            return result['message'].toString();
        }
        if (result is String && result.isNotEmpty) {
            return result;
        }
        return 'Movie deleted successfully';
      },
    );
  }
}
