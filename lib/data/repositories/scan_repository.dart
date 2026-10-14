import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/scan_result_model.dart';
import '../services/sight_engine_service.dart';

class ScanRepository {
  final SightEngineService _service;
  ScanRepository(this._service);

  Future<Either<String, ScanResult>> analyzeImage(File imageFile) async {
    try {
      final response = await _service.checkImage(imageFile);
      final score = response['type']?['ai_generated'];
      if (score is! num || !score.isFinite || score < 0 || score > 1) {
        return const Left('Analiz servisi geçerli bir sonuç döndürmedi.');
      }
      final aiScore = score.toDouble();
      return Right(
        ScanResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageFile: imageFile,
          aiScore: aiScore,
          confidence: aiScore > 0.80
              ? ScanConfidence.high
              : aiScore >= 0.50
              ? ScanConfidence.medium
              : ScanConfidence.low,
          // GenAI probability does not identify a particular generator/model.
          detectedModel: null,
          timestamp: DateTime.now(),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      return Left(switch (e.code) {
        'unauthenticated' => 'Analiz için doğrulanmış hesabınızla giriş yapın.',
        'resource-exhausted' =>
          'Günlük analiz sınırına ulaşıldı. Yarın tekrar deneyin.',
        'failed-precondition' =>
          'Uygulama doğrulanamadı. Güncel sürümü kullanın.',
        'invalid-argument' =>
          'En fazla 5 MB boyutunda JPEG, PNG veya WebP seçin.',
        _ =>
          'Analiz servisine şu anda ulaşılamıyor. Daha sonra tekrar deneyin.',
      });
    } catch (_) {
      return const Left('Analiz tamamlanamadı. Bağlantınızı kontrol edin.');
    }
  }
}
