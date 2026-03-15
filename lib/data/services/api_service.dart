import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the Dio client instance globally.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.sightengine.com/1.0',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'multipart/form-data'},
    ),
  );

  // Custom interceptors can be added here
  return dio;
});

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<Response> uploadImageForAnalysis(String imagePath) async {
    // This is a placeholder for the actual SightEngine API integration
    // SightEngine typically expects api_user and api_secret along with the media
    FormData formData = FormData.fromMap({
      'models':
          'genai', // Assuming 'genai' is the ai-generated-text model for SightEngine
      'api_user': 'YOUR_API_USER',
      'api_secret': 'YOUR_API_SECRET',
      'media': await MultipartFile.fromFile(imagePath),
    });

    return _dio.post('/check.json', data: formData);
  }
}

// Provider for injecting the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});
