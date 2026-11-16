// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_show.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TvShowAdapter extends TypeAdapter<TvShow> {
  @override
  final int typeId = 0;

  @override
  TvShow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TvShow(
      id: fields[0] as int,
      name: fields[1] as String,
      genres: (fields[2] as List).cast<String>(),
      rating: fields[3] as double?,
      imageUrl: fields[4] as String?,
      summary: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TvShow obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.genres)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.summary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TvShowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
