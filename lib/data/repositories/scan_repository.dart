import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../models/scan_result_model.dart';
import '../services/sight_engine_service.dart';

class ScanRepository {
  final SightEngineService _service;

  ScanRepository(this._service);

  Future<Either<String, ScanResult>> analyzeImage(File imageFile) async {
    try {
      final response = await _service.checkImage(imageFile);

      final typeInfo = response['type'] as Map<String, dynamic>?;
      final double aiScore =
          (typeInfo?['ai_generated'] as num?)?.toDouble() ?? 0.0;

      ScanConfidence confidence;
      if (aiScore > 0.80) {
        confidence = ScanConfidence.high;
      } else if (aiScore >= 0.50) {
        confidence = ScanConfidence.medium;
      } else {
        confidence = ScanConfidence.low;
      }

      String? detectedModel;
      if (aiScore > 0.90) {
        detectedModel = "Likely Midjourney/DALL-E";
      } else if (aiScore >= 0.70) {
        detectedModel = "AI Generated (model unknown)";
      }

      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: imageFile,
        aiScore: aiScore,
        confidence: confidence,
        detectedModel: detectedModel,
        timestamp: DateTime.now(),
      );

      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return 'API kimlik doğrulaması başarısız. Lütfen uygulama ayarlarınızı kontrol edin.';
        }
        if (statusCode == 429) {
          return 'Günlük analiz limitine ulaşıldı. Lütfen daha sonra tekrar deneyin.';
        }
        return 'Sunucu hatası oluştu. (Kod: $statusCode) Lütfen tekrar deneyin.';
      case DioExceptionType.connectionError:
        return 'İnternet bağlantısı yok veya sunucuya ulaşılamıyor. Bağlantınızı kontrol edin.';
      default:
        return 'Bir ağ hatası oluştu. Lütfen tekrar deneyin.';
    }
  }
}
