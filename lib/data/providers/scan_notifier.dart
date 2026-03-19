import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_result_model.dart';
import '../models/scan_history_item.dart';
import '../repositories/scan_repository.dart';
import '../repositories/history_repository.dart';
import 'history_notifier.dart';
import 'scan_providers.dart';

// Manual immutable state class for Scan
class ScanState {
  final bool isLoading;
  final ScanResult? result;
  final String? error;

  const ScanState({this.isLoading = false, this.result, this.error});

  factory ScanState.idle() => const ScanState();
  factory ScanState.loading() => const ScanState(isLoading: true);
  factory ScanState.success(ScanResult result) => ScanState(result: result);
  factory ScanState.error(String error) => ScanState(error: error);

  bool get isIdle => !isLoading && result == null && error == null;
}

class ScanNotifier extends Notifier<ScanState> {
  late final ScanRepository _scanRepository;
  late final HistoryRepository _historyRepository;

  @override
  ScanState build() {
    _scanRepository = ref.watch(scanRepositoryProvider);
    _historyRepository = ref.watch(historyRepositoryProvider);
    return const ScanState();
  }

  Future<void> scanImage(File imageFile) async {
    state = ScanState.loading();

    final response = await _scanRepository.analyzeImage(imageFile);

    response.fold((error) => state = ScanState.error(error), (result) async {
      // Create History Item
      final historyItem = ScanHistoryItem(
        id: result
            .id, // Assuming id exists in ScanResult model (needs update there)
        imagePath: result.imageFile.path,
        aiScore: result.aiScore,
        isAiGenerated: result.isAiGenerated,
        confidence: result.confidence.name, // Enum to String
        detectedModel: result.detectedModel,
        timestamp: result.timestamp,
      );

      // Save to Local Storage
      await _historyRepository.saveResult(historyItem);

      // Notify HistoryNotifier to refresh its list
      ref.read(historyNotifierProvider.notifier).loadHistory();

      state = ScanState.success(result);
    });
  }

  void reset() {
    state = ScanState.idle();
  }
}

// Global Provider for History repository (assuming simple instantiation)
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

// The Provider
final scanNotifierProvider = NotifierProvider<ScanNotifier, ScanState>(() {
  return ScanNotifier();
});
