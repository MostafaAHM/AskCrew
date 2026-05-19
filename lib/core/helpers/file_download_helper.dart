import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/messages.dart';
import '../helpers/secure_local_storage.dart';
import '../app_config/app_urls.dart';
import '../app_config/prefs_keys.dart';
import '../app_config/constants.dart';
import '../../config/routes/app_router.dart';

class FileDownloadHelper {
  static Future<bool> downloadFile({
    required String url,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          AppMessages.showError(
            AppRouter.appNavigatorKey.currentContext!,
            'Storage permission is required to download files',
          );
          return false;
        }
      }

      // Get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // For Android, try to get external storage downloads directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          downloadDir = Directory('${externalDir.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
        }
        if (downloadDir == null || !await downloadDir.exists()) {
          downloadDir = await getApplicationDocumentsDirectory();
        }
      } else {
        // For iOS, use documents directory
        downloadDir = await getApplicationDocumentsDirectory();
      }

      // Create file path
      final filePath = '${downloadDir.path}/$fileName';

      // Get auth token
      final token = await SecureLocalStorage.read(PrefsKeys.token);
      final headers = <String, dynamic>{};
      if (token?.isNotEmpty == true) {
        headers[AppConstants.authorization] = '${AppConstants.bearer} $token';
      }

      // Download file
      final dio = Dio();
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        AppMessages.showSuccess(
          AppRouter.appNavigatorKey.currentContext!,
          'File downloaded successfully',
        );
        return true;
      } else {
        AppMessages.showError(
          AppRouter.appNavigatorKey.currentContext!,
          'Failed to download file',
        );
        return false;
      }
    } catch (e) {
      AppMessages.showError(
        AppRouter.appNavigatorKey.currentContext!,
        'Error downloading file: ${e.toString()}',
      );
      return false;
    }
  }

  static Future<bool> downloadCv(String cvUrl, String fileName) async {
    // Ensure URL is complete
    String fullUrl = cvUrl;
    if (!cvUrl.startsWith('http://') && !cvUrl.startsWith('https://')) {
      fullUrl = AppUrls.base + cvUrl;
    }

    return await downloadFile(url: fullUrl, fileName: fileName);
  }
}
