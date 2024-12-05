// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travelhistory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TravelHistoryAdapter extends TypeAdapter<TravelHistory> {
  @override
  final int typeId = 2;

  @override
  TravelHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TravelHistory(
      plan: fields[0] as Plan,
      impression: fields[1] as String,
      story: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TravelHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.plan)
      ..writeByte(1)
      ..write(obj.impression)
      ..writeByte(2)
      ..write(obj.story);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
