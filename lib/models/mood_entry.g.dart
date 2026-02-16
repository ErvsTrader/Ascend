// GENERATED CODE – DO NOT MODIFY BY HAND
// (Hand-written to match what hive_generator would produce.)

part of 'mood_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = moodEntryTypeId;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      date: fields[0] as DateTime,
      moodType: fields[1] as String,
      note: fields[2] as String,
      habitIdsCompleted: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(4) // number of fields
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.moodType)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.habitIdsCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
