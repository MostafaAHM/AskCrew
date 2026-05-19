import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_init_response.dart';
import '../../network/dio_service.dart';
import '../../network/network_request.dart';
import '../../app_config/app_urls.dart';
import '../../di/service_locator.dart';

/// Service for handling unified video upload flow
class VideoUploadService {
  final DioService _dioService = getIt<DioService>();

  /// Step 1: Initialize video upload
  /// Returns video_id, upload_endpoint, and authorization details
  Future<VideoInitResponse> initializeVideo() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(AppUrls.initializeVideo, method: RequestMethod.post),
        mapper: (json) => VideoInitResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error initializing video: $e');
      rethrow;
    }
  }

  /// Initialize video upload for explore content
  /// Returns video_id, upload_endpoint, and authorization details
  Future<VideoInitResponse> initializeExploreVideo() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.initializeExploreVideo,
          method: RequestMethod.post,
        ),
        mapper: (json) => VideoInitResponse.fromJson(json),
      );
      return response;
    } catch (e) {
      debugPrint('Error initializing explore video: $e');
      rethrow;
    }
  }

  /// Step 2: Upload video to BunnyCDN using TUS protocol
  Future<String> uploadVideoToBunny({
    required File videoFile,
    required String videoId,
    required String libraryId,
    required String uploadEndpoint,
    required String authorizationSignature,
    required int authorizationExpire,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
    String? existingUploadLocation,
  }) async {
    try {
      // Create a new Dio instance for TUS upload
      final tusDio = Dio();

      final fileBytes = await videoFile.readAsBytes();
      final fileSize = fileBytes.length;
      final fileName = videoFile.path.split('/').last;

      String uploadLocation;
      int uploadOffset = 0;

      if (existingUploadLocation != null) {
        // Resuming upload
        uploadLocation = existingUploadLocation;
        debugPrint('Resuming upload at: $uploadLocation');

        // Check current offset with HEAD request
        try {
          final headResponse = await tusDio.head(
            uploadLocation,
            options: Options(
              headers: {
                'AuthorizationSignature': authorizationSignature,
                'AuthorizationExpire': authorizationExpire.toString(),
                'VideoId': videoId,
                'LibraryId': libraryId,
                'Tus-Resumable': '1.0.0',
              },
              validateStatus: (status) => status! < 500,
            ),
          );

          if (headResponse.statusCode == 200) {
            final offsetHeader = headResponse.headers.value('Upload-Offset');
            if (offsetHeader != null) {
              uploadOffset = int.parse(offsetHeader);
              debugPrint('Resuming from offset: $uploadOffset');
            }
          }
        } catch (e) {
          debugPrint('Error checking offset, restarting upload: $e');
          uploadOffset = 0;
        }
      } else {
        // New upload
        debugPrint('Starting TUS upload for file: $fileName ($fileSize bytes)');

        // TUS protocol: Create upload session
        final createResponse = await tusDio.post(
          uploadEndpoint,
          options: Options(
            headers: {
              'AuthorizationSignature': authorizationSignature,
              'AuthorizationExpire': authorizationExpire.toString(),
              'VideoId': videoId,
              'LibraryId': libraryId,
              'Tus-Resumable': '1.0.0',
              'Upload-Length': fileSize.toString(),
              'Upload-Metadata': 'filename ${_base64Encode(fileName)}',
            },
            validateStatus: (status) => status! < 500,
          ),
        );

        if (createResponse.statusCode != 201) {
          throw Exception(
            'Failed to create TUS upload: ${createResponse.statusCode}',
          );
        }

        // Get upload location from response headers
        var location = createResponse.headers.value('location');
        if (location == null) {
          throw Exception('No upload location returned from TUS server');
        }

        // If location is relative, make it absolute
        if (!location.startsWith('http')) {
          final baseUrl = uploadEndpoint.replaceAll('/tusupload', '');
          uploadLocation = '$baseUrl$location';
        } else {
          uploadLocation = location;
        }
      }

      // Prepare data for upload (remaining bytes)
      final remainingBytes = fileBytes.sublist(uploadOffset);

      // TUS protocol: Upload file data using PATCH
      final uploadResponse = await tusDio.patch(
        uploadLocation,
        data: remainingBytes,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'AuthorizationSignature': authorizationSignature,
            'AuthorizationExpire': authorizationExpire.toString(),
            'VideoId': videoId,
            'LibraryId': libraryId,
            'Tus-Resumable': '1.0.0',
            'Upload-Offset': uploadOffset.toString(),
            'Content-Type': 'application/offset+octet-stream',
            'Content-Length': remainingBytes.length.toString(),
          },
          validateStatus: (status) => status! < 500,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            // Calculate total progress including already uploaded part
            onProgress(uploadOffset + sent, fileSize);
          }
        },
      );

      if (uploadResponse.statusCode == 204 ||
          uploadResponse.statusCode == 200) {
        debugPrint('✅ Video uploaded successfully to BunnyCDN');
        return uploadLocation;
      } else {
        throw Exception('Failed to upload video: ${uploadResponse.statusCode}');
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        debugPrint('Upload cancelled/paused');
        rethrow;
      }
      debugPrint('❌ Error uploading video to Bunny: $e');
      rethrow;
    }
  }

  String _base64Encode(String text) {
    final bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  /// Complete workflow: Initialize + Upload
  /// Returns the video_id after successful upload
  Future<String> uploadVideo({
    required File videoFile,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Step 1: Initialize
    final initResponse = await initializeVideo();

    // Step 2: Upload to BunnyCDN
    await uploadVideoToBunny(
      videoFile: videoFile,
      videoId: initResponse.videoId,
      libraryId: initResponse.libraryId,
      uploadEndpoint: initResponse.uploadEndpoint,
      authorizationSignature: initResponse.authorizationSignature,
      authorizationExpire: initResponse.authorizationExpire,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    return initResponse.videoId;
  }

  /// Complete workflow: Initialize explore video + Upload
  /// Returns the video_id after successful upload
  Future<String> uploadExploreVideo({
    required File videoFile,
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Step 1: Initialize explore video
    final initResponse = await initializeExploreVideo();

    // Step 2: Upload to BunnyCDN
    await uploadVideoToBunny(
      videoFile: videoFile,
      videoId: initResponse.videoId,
      libraryId: initResponse.libraryId,
      uploadEndpoint: initResponse.uploadEndpoint,
      authorizationSignature: initResponse.authorizationSignature,
      authorizationExpire: initResponse.authorizationExpire,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    return initResponse.videoId;
  }
}
