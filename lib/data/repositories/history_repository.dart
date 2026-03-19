import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/scan_history_item.dart';

class HistoryRepository {
  static const String boxName = 'scan_history';
  static const String _historyImagesDirectoryName = 'history_images';

  // Returns the opened Box
  Box<ScanHistoryItem> get _box => Hive.box<ScanHistoryItem>(boxName);

  Future<void> saveResult(ScanHistoryItem item) async {
    final persistedItem = await _persistHistoryImage(item);

    // Save to Hive
    await _box.put(persistedItem.id, persistedItem);

    // Enforce 100 items limit
    if (_box.length > 100) {
      // Find the oldest item based on timestamp
      final items = _box.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final oldestItem = items.first;
      await _deleteManagedImage(oldestItem.imagePath);
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
    final item = _box.get(id);
    if (item != null) {
      await _deleteManagedImage(item.imagePath);
    }
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    final items = _box.values.toList();
    await _box.clear();
    for (final item in items) {
      await _deleteManagedImage(item.imagePath);
    }
  }

  Future<ScanHistoryItem> _persistHistoryImage(ScanHistoryItem item) async {
    final targetDirectory = await _getHistoryImagesDirectory();
    final targetPath =
        '${targetDirectory.path}${Platform.pathSeparator}'
        '${item.id}${_extensionFor(item.imagePath)}';

    if (item.imagePath == targetPath) {
      return item;
    }

    final sourceFile = File(item.imagePath);
    if (!await sourceFile.exists()) {
      return item;
    }

    final targetFile = File(targetPath);
    await sourceFile.copy(targetPath);

    if (await targetFile.exists() && item.imagePath != targetPath) {
      return item.copyWith(imagePath: targetPath);
    }

    return item;
  }

  Future<Directory> _getHistoryImagesDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final historyDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}'
      '$_historyImagesDirectoryName',
    );

    if (!await historyDirectory.exists()) {
      await historyDirectory.create(recursive: true);
    }

    return historyDirectory;
  }

  Future<void> _deleteManagedImage(String imagePath) async {
    if (!await _isManagedHistoryImage(imagePath)) {
      return;
    }

    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }

  Future<bool> _isManagedHistoryImage(String imagePath) async {
    final historyDirectory = await _getHistoryImagesDirectory();
    return imagePath.startsWith(historyDirectory.path);
  }

  String _extensionFor(String imagePath) {
    final fileName = imagePath.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1) {
      return '.jpg';
    }

    return fileName.substring(dotIndex);
  }
}
