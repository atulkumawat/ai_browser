import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
import '../models/browser_tab.dart';
import '../models/file_item.dart';
class StorageService extends GetxService {
  late Box<BrowserTab> _tabsBox;
  late Box<FileItem> _filesBox;
  late Box _settingsBox;
  Future<StorageService> init() async {
    Hive.registerAdapter(BrowserTabAdapter());
    Hive.registerAdapter(FileItemAdapter());
    _tabsBox = await Hive.openBox<BrowserTab>('tabs');
    _filesBox = await Hive.openBox<FileItem>('files');
    _settingsBox = await Hive.openBox('settings');
    return this;
  }
  Future<void> saveTabs(List<BrowserTab> tabs) async {
    await _tabsBox.clear();
    for (var tab in tabs) {
      await _tabsBox.put(tab.id, tab);
    }
  }
  List<BrowserTab> getTabs() {
    return _tabsBox.values.toList();
  }
  Future<void> saveFile(FileItem file) async {
    await _filesBox.put(file.id, file);
  }
  List<FileItem> getFiles() {
    return _filesBox.values.toList();
  }
  Future<void> deleteFile(String id) async {
    await _filesBox.delete(id);
  }
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  T? getSetting<T>(String key) {
    return _settingsBox.get(key);
  }
}
