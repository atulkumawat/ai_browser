import 'package:hive/hive.dart';
part 'browser_tab.g.dart';
@HiveType(typeId: 0)
class BrowserTab extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String url;
  @HiveField(3)
  bool isActive;
  @HiveField(4)
  DateTime lastAccessed;
  @HiveField(5)
  String? summary;
  @HiveField(6)
  Map<String, String>? translations;
  BrowserTab({
    required this.id,
    required this.title,
    required this.url,
    this.isActive = false,
    required this.lastAccessed,
    this.summary,
    this.translations,
  });
}
