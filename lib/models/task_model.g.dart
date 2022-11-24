// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      description: fields[1] as String,
      sort: fields[2] as int,
      synSort: fields[100] as bool,
      synUpdate: fields[101] as bool,
      itemLocation:
          fields[3] == null ? ItemLocation.inbox : fields[3] as ItemLocation,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.sort)
      ..writeByte(3)
      ..write(obj.itemLocation)
      ..writeByte(100)
      ..write(obj.synSort)
      ..writeByte(101)
      ..write(obj.synUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 2;

  @override
  Folder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Folder(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemLocationAdapter extends TypeAdapter<ItemLocation> {
  @override
  final int typeId = 4;

  @override
  ItemLocation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemLocation.inbox;
      case 1:
        return ItemLocation.today;
      case 3:
        return ItemLocation.ohter;
      default:
        return ItemLocation.inbox;
    }
  }

  @override
  void write(BinaryWriter writer, ItemLocation obj) {
    switch (obj) {
      case ItemLocation.inbox:
        writer.writeByte(0);
        break;
      case ItemLocation.today:
        writer.writeByte(1);
        break;
      case ItemLocation.ohter:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
