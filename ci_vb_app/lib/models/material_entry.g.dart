// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build
// lib/models/material_entry.g.dart

part of 'material_entry.dart';

class MaterialEntryAdapter extends TypeAdapter<MaterialEntry> {
  @override
  final int typeId = 0;

  @override
  MaterialEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialEntry(
      name: fields[0] as String,
      colB: fields[1] as double?,
      gM2: fields[2] as double?,
      thicknessUm: fields[3] as double?,
      colE: fields[4] as double?,
      colF: fields[5] as double?,
      weightFactor: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.colB)
      ..writeByte(2)
      ..write(obj.gM2)
      ..writeByte(3)
      ..write(obj.thicknessUm)
      ..writeByte(4)
      ..write(obj.colE)
      ..writeByte(5)
      ..write(obj.colF)
      ..writeByte(6)
      ..write(obj.weightFactor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
