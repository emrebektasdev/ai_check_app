import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import '../models/scan_result_model.dart';
import '../services/api_service.dart';

// Abstract Interface
abstract class SightEngineRepository {
  Future<Either<String, ScanResult>> analyzeImage(String imagePath);
}

// Implementation
class SightEngineRepositoryImpl implements SightEngineRepository {
  final ApiService _apiService;

  SightEngineRepositoryImpl(this._apiService);

  @override
  Future<Either<String, ScanResult>> analyzeImage(String imagePath) async {
    try {
      final response = await _apiService.uploadImageForAnalysis(imagePath);

      if (response.statusCode == 200) {
        final data = response.data;
        // Parse SightEngine GenAI probability from the response
        // This assumes the API returns a probability score for AI generation
        final aiProbability = data['type']['ai_generated'] ?? 0.0;

        final aiScore = aiProbability.toDouble();
        final confidence = aiScore > 0.8
            ? ScanConfidence.high
            : (aiScore > 0.4 ? ScanConfidence.medium : ScanConfidence.low);
        final result = ScanResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageFile: File(imagePath),
          aiScore: aiScore,
          confidence: confidence,
          timestamp: DateTime.now(),
        );
        return Right(result);
      } else {
        return const Left('Sunucu hatası oluştu. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      return Left('Bağlantı hatası: ${e.toString()}');
    }
  }
}

// Global Repository Provider
final sightEngineRepositoryProvider = Provider<SightEngineRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SightEngineRepositoryImpl(apiService);
});
