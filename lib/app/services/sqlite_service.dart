import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import '../models/browser_tab.dart';
import '../models/file_item.dart';
class SQLiteService extends GetxService {
  Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ai_browser.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tabs(
            id TEXT PRIMARY KEY,
            title TEXT,
            url TEXT,
            isActive INTEGER,
            lastAccessed INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE files(
            id TEXT PRIMARY KEY,
            name TEXT,
            path TEXT,
            type TEXT,
            size INTEGER,
            downloadedAt INTEGER,
            summary TEXT,
            translations TEXT
          )
        ''');
      },
    );
  }
  Future<void> saveTabs(List<BrowserTab> tabs) async {
    final db = await database;
    await db.delete('tabs');
    for (final tab in tabs) {
      await db.insert('tabs', {
        'id': tab.id,
        'title': tab.title,
        'url': tab.url,
        'isActive': tab.isActive ? 1 : 0,
        'lastAccessed': tab.lastAccessed.millisecondsSinceEpoch,
      });
    }
  }
  Future<List<BrowserTab>> getTabs() async {
    final db = await database;
    final maps = await db.query('tabs');
    return maps.map((map) => BrowserTab(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      isActive: (map['isActive'] as int) == 1,
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(map['lastAccessed'] as int),
    )).toList();
  }
}
