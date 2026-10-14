import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sight_engine_service.dart';
import '../repositories/scan_repository.dart';
import '../models/scan_result_model.dart';

final sightEngineServiceProvider = Provider<SightEngineService>((ref) {
  return SightEngineService(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  );
});
final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(ref.watch(sightEngineServiceProvider));
});
final scanResultProvider = FutureProvider.family<ScanResult, File>((
  ref,
  imageFile,
) async {
  final result = await ref
      .watch(scanRepositoryProvider)
      .analyzeImage(imageFile);
  return result.fold((message) => throw Exception(message), (result) => result);
});
