// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_gemma/flutter_gemma_interface.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class DownloadCancelledException implements Exception {
//   final String message;
//   DownloadCancelledException([this.message = 'Download cancelled']);
//   @override
//   String toString() => message;
// }

// class DownloadForbiddenException implements Exception {
//   final String message;
//   DownloadForbiddenException([this.message = 'Forbidden (403)']);
//   @override
//   String toString() => message;
// }

// class ModelDownloadService {
//   ModelDownloadService({
//     required this.modelUrl,
//     required this.modelFilename,
//     required this.licenseUrl,
//   });

//   final String modelUrl;
//   final String modelFilename;
//   final String licenseUrl;

//   /// Helper method to get the file path.
//   Future<String> getFilePath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return '${directory.path}/$modelFilename';
//   }

//   /// Checks if the model file exists and matches the remote file size.
//   Future<bool> checkModelExistence(String token) async {
//     try {
//       final filePath = await getFilePath();
//       final file = File(filePath);

//       // Check remote file size
//       final Map<String, String> headers = token.isNotEmpty
//           ? {'Authorization': 'Bearer $token'}
//           : {};
//       final headResponse = await http.head(
//         Uri.parse(modelUrl),
//         headers: headers,
//       );

//       if (headResponse.statusCode == 200) {
//         final contentLengthHeader = headResponse.headers['content-length'];
//         if (contentLengthHeader != null) {
//           final remoteFileSize = int.parse(contentLengthHeader);
//           if (file.existsSync() && await file.length() == remoteFileSize) {
//             return true;
//           }
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error checking model existence: $e');
//       }
//     }
//     return false;
//   }

//   /// Downloads the model file and tracks progress. Supports cancellation.
//   Future<bool> downloadModel({
//     required String token,
//     required Function(double) onProgress,
//     required ValueNotifier<bool> cancelNotifier,
//     VoidCallback? onComplete,
//   }) async {
//     try {
//       // Reset progress at start
//       onProgress(0);
//       final stream = FlutterGemmaPlugin.instance.modelManager
//           .downloadModelFromNetworkWithProgress(modelUrl, token: token);

//       await for (final progress in stream) {
//         if (cancelNotifier.value) {
//           if (kDebugMode) debugPrint('Download cancelled by user');
//           throw DownloadCancelledException();
//         }
//         // Plugin có thể trả về -1 khi lỗi HTTP => đọc missing rule
//         if (progress == -403) {
//           throw DownloadForbiddenException();
//         }
//         if (progress >= 0) {
//           onProgress(progress.toDouble());
//         }

//         if (progress >= 100) {
//           if (onComplete != null) {
//             onComplete();
//           }
//           break;
//         }
//       }
//       return true;
//     } on DownloadCancelledException {
//       rethrow;
//     } on DownloadForbiddenException {
//       rethrow;
//     } catch (e) {
//       if (kDebugMode) debugPrint('Error downloading model: $e');
//       return false;
//     }
//   }

//   /// Deletes the downloaded file.
//   Future<void> deleteModel() async {
//     try {
//       final filePath = await getFilePath();
//       final file = File(filePath);

//       if (file.existsSync()) {
//         await file.delete();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error deleting model: $e');
//       }
//     }
//   }
// }
