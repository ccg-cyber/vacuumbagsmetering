// GENERATED CODE - DO NOT MODIFY BY HAND
// lib/models/cost_entry.g.dart

part of 'cost_entry.dart';

class CostEntryAdapter extends TypeAdapter<CostEntry> {
  @override
  final int typeId = 1;

  @override
  CostEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CostEntry(
      name: fields[0] as String,
      cost: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CostEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.cost);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
