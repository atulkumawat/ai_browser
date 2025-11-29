part of 'file_item.dart';
class FileItemAdapter extends TypeAdapter<FileItem> {
  @override
  final int typeId = 1;
  @override
  FileItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileItem(
      id: fields[0] as String,
      name: fields[1] as String,
      path: fields[2] as String,
      type: fields[3] as String,
      size: fields[4] as int,
      downloadedAt: fields[5] as DateTime,
      summary: fields[6] as String?,
      translations: (fields[7] as Map?)?.cast<String, String>(),
    );
  }
  @override
  void write(BinaryWriter writer, FileItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.downloadedAt)
      ..writeByte(6)
      ..write(obj.summary)
      ..writeByte(7)
      ..write(obj.translations);
  }
  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
