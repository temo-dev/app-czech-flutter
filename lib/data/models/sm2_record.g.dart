// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sm2_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Sm2RecordAdapter extends TypeAdapter<Sm2Record> {
  @override
  final int typeId = 0;

  @override
  Sm2Record read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sm2Record(
      vocabId: fields[0] as String,
      easeFactor: fields[1] as double,
      interval: fields[2] as int,
      repetitions: fields[3] as int,
      nextReviewDate: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sm2Record obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.vocabId)
      ..writeByte(1)
      ..write(obj.easeFactor)
      ..writeByte(2)
      ..write(obj.interval)
      ..writeByte(3)
      ..write(obj.repetitions)
      ..writeByte(4)
      ..write(obj.nextReviewDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sm2RecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
