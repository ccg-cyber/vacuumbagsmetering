// GENERATED CODE - DO NOT MODIFY BY HAND
// lib/models/saved_job.g.dart

part of 'saved_job.dart';

class SavedJobAdapter extends TypeAdapter<SavedJob> {
  @override
  final int typeId = 2;

  @override
  SavedJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedJob(
      jobName: fields[0] as String,
      customerName: fields[1] as String?,
      itemCode: fields[2] as String?,
      note: fields[3] as String?,
      productType: fields[4] as String,
      l: fields[5] as double,
      w: fields[6] as double,
      g: fields[7] as double,
      qty: fields[8] as double,
      numLayers: fields[9] as int,
      layer1: fields[10] as String,
      layer2: fields[11] as String,
      layer3: fields[12] as String,
      layer4: fields[13] as String,
      createdAt: fields[14] as DateTime,
      weightKg1: fields[15] as double?,
      weightKg2: fields[16] as double?,
      weightKg3: fields[17] as double?,
      weightKg4: fields[18] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedJob obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.jobName)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.itemCode)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.productType)
      ..writeByte(5)
      ..write(obj.l)
      ..writeByte(6)
      ..write(obj.w)
      ..writeByte(7)
      ..write(obj.g)
      ..writeByte(8)
      ..write(obj.qty)
      ..writeByte(9)
      ..write(obj.numLayers)
      ..writeByte(10)
      ..write(obj.layer1)
      ..writeByte(11)
      ..write(obj.layer2)
      ..writeByte(12)
      ..write(obj.layer3)
      ..writeByte(13)
      ..write(obj.layer4)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.weightKg1)
      ..writeByte(16)
      ..write(obj.weightKg2)
      ..writeByte(17)
      ..write(obj.weightKg3)
      ..writeByte(18)
      ..write(obj.weightKg4);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedJobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
