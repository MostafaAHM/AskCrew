// import 'dart:io';
// import 'package:path/path.dart';

// class FileHelper {
//   static ChatFileType getFileType(File file) {
//     String fileExtension = extension(file.path).toLowerCase();

//     if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension)) {
//       return ChatFileType.image;
//     } else if (fileExtension == '.pdf') {
//       return ChatFileType.pdf;
//     } else if (['.mp3', '.wav', '.aac', '.m4a'].contains(fileExtension)) {
//       return ChatFileType.audio;
//     } else {
//       return ChatFileType.none;
//     }
//   }

//   static bool isImageFile(File file) {
//     final List<String> imageExtensions = [
//       'jpg',
//       'jpeg',
//       'png',
//       'gif',
//       'bmp',
//       'webp'
//     ];

//     // Get file extension
//     String extension = file.path.split('.').last.toLowerCase();

//     return imageExtensions.contains(extension);
//   }

//   static String getFileNameFromFile(File file) {
//     return basename(file.path); // Extracts filename with extension
//   }

//   static String getFileNameFromUrl(String url) {
//     return Uri.parse(url).pathSegments.last; // Extracts filename with extension
//   }
// }
