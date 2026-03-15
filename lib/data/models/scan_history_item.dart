import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ScanHistoryItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final double aiScore;

  @HiveField(3)
  final bool isAiGenerated;

  @HiveField(4)
  final String confidence;

  @HiveField(5)
  final String? detectedModel;

  @HiveField(6)
  final DateTime timestamp;

  const ScanHistoryItem({
    required this.id,
    required this.imagePath,
    required this.aiScore,
    required this.isAiGenerated,
    required this.confidence,
    this.detectedModel,
    required this.timestamp,
  });

  // copyWith method helps with immutability, though primarily used for state models
  ScanHistoryItem copyWith({
    String? id,
    String? imagePath,
    double? aiScore,
    bool? isAiGenerated,
    String? confidence,
    String? detectedModel,
    DateTime? timestamp,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      aiScore: aiScore ?? this.aiScore,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      confidence: confidence ?? this.confidence,
      detectedModel: detectedModel ?? this.detectedModel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ScanHistoryItemAdapter extends TypeAdapter<ScanHistoryItem> {
  @override
  final int typeId = 0;

  @override
  ScanHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryItem(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      aiScore: fields[2] as double,
      isAiGenerated: fields[3] as bool,
      confidence: fields[4] as String,
      detectedModel: fields[5] as String?,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryItem obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.aiScore)
      ..writeByte(3)
      ..write(obj.isAiGenerated)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.detectedModel)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
