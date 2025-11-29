part of 'browser_tab.dart';
class BrowserTabAdapter extends TypeAdapter<BrowserTab> {
  @override
  final int typeId = 0;
  @override
  BrowserTab read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrowserTab(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      isActive: fields[3] as bool,
      lastAccessed: fields[4] as DateTime,
    );
  }
  @override
  void write(BinaryWriter writer, BrowserTab obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.lastAccessed);
  }
  @override
  int get hashCode => typeId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserTabAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
