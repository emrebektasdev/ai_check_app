import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_history_item.dart';

class HistoryRepository {
  static const String boxName = 'scan_history';

  // Returns the opened Box
  Box<ScanHistoryItem> get _box => Hive.box<ScanHistoryItem>(boxName);

  Future<void> saveResult(ScanHistoryItem item) async {
    // Save to Hive
    await _box.put(item.id, item);

    // Enforce 100 items limit
    if (_box.length > 100) {
      // Find the oldest item based on timestamp
      final items = _box.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final oldestItem = items.first;
      await _box.delete(oldestItem.id);
    }
  }

  List<ScanHistoryItem> getAllHistory() {
    // Return sorted items (newest first)
    final items = _box.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> deleteResult(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
