import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../services/sight_engine_service.dart';
import '../repositories/scan_repository.dart';
import '../models/scan_result_model.dart';

final apiDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.sightEngineApiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
});

final sightEngineServiceProvider = Provider<SightEngineService>((ref) {
  return SightEngineService(ref.watch(apiDioProvider));
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(ref.watch(sightEngineServiceProvider));
});

// A FutureProvider.family that accepts a File and returns the ScanResult.
final scanResultProvider = FutureProvider.family<ScanResult, File>((
  ref,
  imageFile,
) async {
  final repository = ref.watch(scanRepositoryProvider);
  final result = await repository.analyzeImage(imageFile);

  return result.fold(
    (errorMsg) => throw Exception(errorMsg),
    (scanResult) => scanResult,
  );
});
