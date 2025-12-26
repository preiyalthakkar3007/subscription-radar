// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      subName: fields[0] as String,
      cost: fields[1] as double,
      cycle: fields[2] as String,
      nextDueMs: fields[3] as int,
      category: fields[4] as String,
      isCancelled: fields[5] as bool,
      remindersOn: fields[6] as bool,
      remindDaysBefore: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.subName)
      ..writeByte(1)
      ..write(obj.cost)
      ..writeByte(2)
      ..write(obj.cycle)
      ..writeByte(3)
      ..write(obj.nextDueMs)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isCancelled)
      ..writeByte(6)
      ..write(obj.remindersOn)
      ..writeByte(7)
      ..write(obj.remindDaysBefore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
