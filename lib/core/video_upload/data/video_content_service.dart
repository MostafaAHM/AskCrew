import 'package:flutter/foundation.dart';
import '../models/video_content_request.dart';
import '../../network/dio_service.dart';
import '../../network/network_request.dart';
import '../../app_config/app_urls.dart';
import '../../di/service_locator.dart';

/// Service for finalizing video content after upload
class VideoContentService {
  final DioService _dioService = getIt<DioService>();

  /// Finalize video content (movie, episode, etc.)
  /// This is Step 3 of the upload flow
  Future<Map<String, dynamic>> finalizeContent(
    VideoContentRequest request,
  ) async {
    try {
      final endpoint = '${AppUrls.baseApi}${request.endpoint}';

      final response = await _dioService.callApi(
        NetworkRequest(
          endpoint,
          method: RequestMethod.post,
          body: request.toJson(),
        ),
      );

      debugPrint('Content finalized successfully: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error finalizing content: $e');
      rethrow;
    }
  }

  /// Create a movie record
  Future<Map<String, dynamic>> createMovie(CreateMovieRequest request) async {
    return await finalizeContent(request);
  }

  /// Create an episode record
  Future<Map<String, dynamic>> createEpisode(
    CreateEpisodeRequest request,
  ) async {
    return await finalizeContent(request);
  }
}
