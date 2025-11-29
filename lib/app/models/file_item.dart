import 'package:hive/hive.dart';
part 'file_item.g.dart';
@HiveType(typeId: 1)
class FileItem extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String path;
  @HiveField(3)
  String type;
  @HiveField(4)
  int size;
  @HiveField(5)
  DateTime downloadedAt;
  @HiveField(6)
  String? summary;
  @HiveField(7)
  Map<String, String>? translations;
  FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.downloadedAt,
    this.summary,
    this.translations,
  });
}
