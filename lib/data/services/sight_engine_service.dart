import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class SightEngineService {
  final Dio _dio;

  SightEngineService(this._dio);

  Future<Map<String, dynamic>> checkImage(File imageFile) async {
    const int maxRetries = 2;
    int retryCount = 0;

    while (true) {
      try {
        FormData formData = FormData.fromMap({
          'models': 'genai',
          'api_user': AppConstants.sightEngineApiUser,
          'api_secret': AppConstants.sightEngineApiSecret,
          'media': await MultipartFile.fromFile(imageFile.path),
        });

        // The timeout is specified in the Dio instance directly (in scan_providers.dart)
        final response = await _dio.post('/check.json', data: formData);

        if (response.statusCode == 200 &&
            response.data['status'] == 'success') {
          return response.data;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error:
                'API Hatası: Beklenmeyen yanıt formatı / Unexpected API response format.',
          );
        }
      } on DioException catch (_) {
        if (retryCount >= maxRetries) {
          rethrow;
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2)); // Backoff
      }
    }
  }
}
