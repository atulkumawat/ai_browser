import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/browser_tab.dart';
import '../../../services/storage_service.dart';
import '../../browser/controllers/browser_controller.dart';
class HistoryController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  var activeTabs = <BrowserTab>[].obs;
  var historyItems = <HistoryItem>[].obs;
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  @override
  void onReady() {
    super.onReady();
    loadData();
  }
  void loadData() {
    loadActiveTabs();
    loadHistory();
  }
  void loadActiveTabs() {
    activeTabs.value = _storage.getTabs();
  }
  void loadHistory() {
    try {
      final savedHistory = _storage.getSetting<List>('browsing_history') ?? [];
      historyItems.value = savedHistory.map((item) {
        if (item is Map<String, dynamic>) {
          return HistoryItem.fromMap(item);
        } else {
          return HistoryItem.fromMap(Map<String, dynamic>.from(item));
        }
      }).toList();
      historyItems.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    } catch (e) {
      print('Error loading history: $e');
      historyItems.value = [];
    }
  }
  void addToHistory(String url, String title) {
    final existingIndex = historyItems.indexWhere((item) => item.url == url);
    if (existingIndex != -1) {
      historyItems[existingIndex].visitedAt = DateTime.now();
      historyItems[existingIndex].visitCount++;
    } else {
      historyItems.insert(0, HistoryItem(
        url: url,
        title: title,
        visitedAt: DateTime.now(),
        visitCount: 1,
      ));
    }
    if (historyItems.length > 100) {
      historyItems.removeRange(100, historyItems.length);
    }
    saveHistory();
  }
  void saveHistory() {
    try {
      final historyMaps = historyItems.map((item) => item.toMap()).toList();
      _storage.saveSetting('browsing_history', historyMaps);
    } catch (e) {
      print('Error saving history: $e');
    }
  }
  void clearHistory() {
    historyItems.clear();
    _storage.saveSetting('browsing_history', []);
  }
  void deleteHistoryItem(String url) {
    historyItems.removeWhere((item) => item.url == url);
    saveHistory();
  }
  void openUrl(String url) {
    final browserController = Get.find<BrowserController>();
    browserController.navigateToUrl(url);
    Get.back(); // Go back to browser
  }
  void switchToTab(BrowserTab tab) {
    final browserController = Get.find<BrowserController>();
    final tabIndex = browserController.tabs.indexWhere((t) => t.id == tab.id);
    if (tabIndex != -1) {
      browserController.switchTab(tabIndex);
      Get.back();
    }
  }
  void closeTab(String tabId) {
    final browserController = Get.find<BrowserController>();
    final tabIndex = browserController.tabs.indexWhere((t) => t.id == tabId);
    if (tabIndex != -1) {
      browserController.closeTab(tabIndex);
      loadActiveTabs();
    }
  }
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
class HistoryItem {
  String url;
  String title;
  DateTime visitedAt;
  int visitCount;
  HistoryItem({
    required this.url,
    required this.title,
    required this.visitedAt,
    this.visitCount = 1,
  });
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'visitedAt': visitedAt.millisecondsSinceEpoch,
      'visitCount': visitCount,
    };
  }
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      visitedAt: DateTime.fromMillisecondsSinceEpoch(map['visitedAt'] ?? 0),
      visitCount: map['visitCount'] ?? 1,
    );
  }
}
