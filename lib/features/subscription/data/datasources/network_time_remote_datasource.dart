import 'dart:io';
import 'package:dio/dio.dart';

class NetworkTimeRemoteDataSource {
  final Dio _dio;

  NetworkTimeRemoteDataSource(this._dio);

  /// Lấy thời gian từ API public (ở đây gọi check Google.com để lấy Date header)
  /// Đây là cách rất ổn định và nhanh, không bị limit như WorldTimeAPI.
  Future<DateTime> getCurrentNetworkTime() async {
    try {
      final response = await _dio.head(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final dateHeader = response.headers.value('Date');
      if (dateHeader != null) {
        // Parse "Thu, 05 Apr 2026 09:12:33 GMT"
        // HttpDate.parse helps with standard HTTP dates
        return HttpDate.parse(dateHeader);
      }
      return DateTime.now().toUtc(); // Fallback if header missing
    } catch (e) {
      // Offline fallback: throw exception để Repository biết và dùng Offline Fallback Grace Period
      throw Exception('Network time unavailable: $e');
    }
  }
}
