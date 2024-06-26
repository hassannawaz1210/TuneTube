// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlaylistItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistItemAdapter extends TypeAdapter<PlaylistItem> {
  @override
  final int typeId = 0;

  @override
  PlaylistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistItem(
      title: fields[0] as String,
      author: fields[1] as String,
      thumbnails: fields[2] as String,
      videoUrl: fields[4] as String,
      description: fields[5] as String,
      duration: fields[6] as String,
    )..audioUrl = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, PlaylistItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.thumbnails)
      ..writeByte(3)
      ..write(obj.audioUrl)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
