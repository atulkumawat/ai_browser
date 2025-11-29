import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ThemeService _theme = Get.find<ThemeService>();
  var isDarkMode = false.obs;
  var autoSummarize = false.obs;
  var saveHistory = true.obs;
  var cacheSize = '0 MB'.obs;
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  void loadSettings() {
    isDarkMode.value = _theme.isDarkMode.value;
    autoSummarize.value = _storage.getSetting('auto_summarize') ?? false;
    saveHistory.value = _storage.getSetting('save_history') ?? true;
    calculateCacheSize();
  }
  void toggleTheme() {
    _theme.toggleTheme();
    isDarkMode.value = _theme.isDarkMode.value;
  }
  void toggleAutoSummarize(bool value) {
    autoSummarize.value = value;
    _storage.saveSetting('auto_summarize', value);
  }
  void toggleSaveHistory(bool value) {
    saveHistory.value = value;
    _storage.saveSetting('save_history', value);
  }
  void clearCache() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Cache'),
        content: Text('This will clear all cached data including summaries and translations. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _storage.saveSetting('browsing_history', []);
              Get.back();
              Get.snackbar('Success', 'Cache cleared successfully');
              calculateCacheSize();
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void calculateCacheSize() {
    cacheSize.value = '2.5 MB';
  }
  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI Browser'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('AI-Powered In-App Browser & Document Summarizer'),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• AI-powered content summarization'),
            Text('• Multi-language translation'),
            Text('• File management & processing'),
            Text('• Browsing history & tab management'),
            Text('• Cross-platform support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
