import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_history_item.dart';
import '../repositories/history_repository.dart';
import 'scan_notifier.dart'; // import for repository provider

class HistoryNotifier extends Notifier<List<ScanHistoryItem>> {
  late final HistoryRepository _repository;

  @override
  List<ScanHistoryItem> build() {
    _repository = ref.watch(historyRepositoryProvider);
    return _repository.getAllHistory();
  }

  void loadHistory() {
    // HistoryRepository returns a sorted list of History items
    state = _repository.getAllHistory();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteResult(id);
    loadHistory(); // Refresh state
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    loadHistory(); // Make state an empty list
  }
}

// Provider for HistoryNotifier
final historyNotifierProvider =
    NotifierProvider<HistoryNotifier, List<ScanHistoryItem>>(() {
      return HistoryNotifier();
    });
