import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result_model.freezed.dart';

enum ScanConfidence { high, medium, low }

@freezed
abstract class ScanResult with _$ScanResult {
  const ScanResult._();

  const factory ScanResult({
    required String id,
    required File imageFile,
    required double aiScore,
    required ScanConfidence confidence,
    String? detectedModel,
    required DateTime timestamp,
  }) = _ScanResult;

  bool get isAiGenerated => aiScore > 0.5;
}
