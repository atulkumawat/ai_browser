import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/browser_tab.dart';
import '../../../services/storage_service.dart';
import '../../../services/ai_service.dart';
import '../../../services/web_scraper_service.dart';
import '../../../services/download_service.dart';
import '../../../services/analytics_service.dart';
import '../../tabs/controllers/tabs_controller.dart';
class BrowserController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AIService _aiService = Get.put(AIService());
  final WebScraperService _webScraper = Get.put(WebScraperService());
  final DownloadService _downloadService = Get.put(DownloadService());
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  var tabs = <BrowserTab>[].obs;
  var currentTabIndex = 0.obs;
  var isLoading = false.obs;
  var webViewLoading = false.obs;
  var webViewError = false.obs;
  var urlController = TextEditingController();
  var showSummaryPanel = false.obs;
  String get currentSummary {
    if (tabs.isEmpty) return '';
    print('Getting summary for tab ${currentTabIndex.value}: ${tabs[currentTabIndex.value].url}');
    return tabs[currentTabIndex.value].summary ?? '';
  }
  Map<String, String> get currentTranslations {
    if (tabs.isEmpty) return {};
    return tabs[currentTabIndex.value].translations ?? {};
  }
  var selectedLanguage = 'summary'.obs;
  var navigationHistory = <String>[].obs;
  var currentHistoryIndex = 0.obs;
  @override
  void onInit() {
    super.onInit();
    loadTabs();
    if (tabs.isEmpty) {
      addNewTab('https://example.com');
    }
    ever(selectedLanguage, (String language) {
      if (language != 'summary' && currentSummary.isNotEmpty) {
        translateToLanguage(language);
      }
    });
  }
  Future<void> translateToLanguage(String language) async {
    if (currentSummary.isEmpty) {
      return;
    }
    final currentTab = tabs[currentTabIndex.value];
    currentTab.translations ??= {};
    if (currentTab.translations!.containsKey(language) && currentTab.translations![language]!.isNotEmpty) {
      return; // Translation already exists
    }
    try {
      isLoading.value = true;
      final translation = await _aiService.translateToLanguage(currentSummary, language);
      currentTab.translations![language] = translation;
      tabs.refresh();
      saveTabs();
    } catch (e) {
      print('Translation failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
  void loadTabs() {
    final savedTabs = _storage.getTabs();
    if (savedTabs.isNotEmpty) {
      tabs.value = savedTabs;
      final activeTab = tabs.firstWhereOrNull((tab) => tab.isActive);
      if (activeTab != null) {
        currentTabIndex.value = tabs.indexOf(activeTab);
      }
    }
  }
  void addNewTab(String url) {
    final newTab = BrowserTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: getTabTitle(url),
      url: url,
      isActive: true,
      lastAccessed: DateTime.now(),
    );
    for (var tab in tabs) {
      tab.isActive = false;
    }
    tabs.add(newTab);
    currentTabIndex.value = tabs.length - 1;
    urlController.text = url;
    navigationHistory.clear();
    navigationHistory.add(url);
    currentHistoryIndex.value = 0;
    Future.microtask(() => saveTabs());
  }
  void switchTab(int index) {
    if (index < tabs.length) {
      print('Switching from tab ${currentTabIndex.value} to tab $index');
      print('New tab URL: ${tabs[index].url}');
      if (currentTabIndex.value < tabs.length) {
        tabs[currentTabIndex.value].isActive = false;
      }
      currentTabIndex.value = index;
      tabs[index].isActive = true;
      tabs[index].lastAccessed = DateTime.now();
      urlController.text = tabs[index].url;
      tabs.refresh();
      print('Current tab index after switch: ${currentTabIndex.value}');
      Future.microtask(() => saveTabs());
    }
  }
  void closeTab(int index) {
    if (tabs.length > 1 && index < tabs.length) {
      tabs.removeAt(index);
      if (currentTabIndex.value >= tabs.length) {
        currentTabIndex.value = tabs.length - 1;
      }
      if (tabs.isNotEmpty) {
        tabs[currentTabIndex.value].isActive = true;
        urlController.text = tabs[currentTabIndex.value].url;
      }
      Future.microtask(() => saveTabs());
    }
  }
  void navigateToUrl(String url) {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final currentTab = tabs[currentTabIndex.value];
    if (navigationHistory.isEmpty || navigationHistory.last != url) {
      if (currentHistoryIndex.value < navigationHistory.length - 1) {
        navigationHistory.removeRange(currentHistoryIndex.value + 1, navigationHistory.length);
      }
      navigationHistory.add(url);
      currentHistoryIndex.value = navigationHistory.length - 1;
    }
    currentTab.url = url;
    currentTab.title = getTabTitle(url);
    currentTab.lastAccessed = DateTime.now();
    urlController.text = url;
    try {
      final historyController = Get.find<HistoryController>();
      historyController.addToHistory(url, currentTab.title);
    } catch (e) {
      print('History controller not found: $e');
    }
    saveTabs();
  }
  bool canGoBack() {
    return currentHistoryIndex.value > 0;
  }
  bool canGoForward() {
    return currentHistoryIndex.value < navigationHistory.length - 1;
  }
  void goBack() {
    if (canGoBack()) {
      currentHistoryIndex.value--;
      final url = navigationHistory[currentHistoryIndex.value];
      final currentTab = tabs[currentTabIndex.value];
      currentTab.url = url;
      urlController.text = url;
      saveTabs();
      Get.snackbar('Info', 'Navigated back to: $url');
    }
  }
  void goForward() {
    if (canGoForward()) {
      currentHistoryIndex.value++;
      final url = navigationHistory[currentHistoryIndex.value];
      final currentTab = tabs[currentTabIndex.value];
      currentTab.url = url;
      urlController.text = url;
      saveTabs();
      Get.snackbar('Info', 'Navigated forward to: $url');
    }
  }
  void refreshPage() {
    final currentTab = tabs[currentTabIndex.value];
    String currentUrl = urlController.text.trim();
    if (currentUrl.isNotEmpty) {
      if (!currentUrl.startsWith('http')) {
        currentUrl = 'https://$currentUrl';
      }
      currentTab.url = currentUrl;
    }
    currentTab.lastAccessed = DateTime.now();
    saveTabs();
    tabs.refresh(); // Force UI update
    Get.snackbar('Info', 'Page refreshed: ${currentTab.url}');
  }
  Future<void> copyContent() async {
    String content = '';
    if (selectedLanguage.value == 'summary') {
      content = currentSummary;
    } else {
      content = currentTranslations[selectedLanguage.value] ?? '';
    }
    if (content.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: content));
        Get.snackbar('Success', 'Content copied to clipboard!', backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Error', 'Failed to copy: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'No content to copy', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  void shareContent() {
    String content = '';
    if (selectedLanguage.value == 'summary') {
      content = currentSummary;
    } else {
      content = currentTranslations[selectedLanguage.value] ?? '';
    }
    if (content.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Share Content'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy, color: Colors.blue),
                title: Text('Copy to Clipboard'),
                onTap: () {
                  Get.back();
                  copyContent();
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.facebook, color: Colors.blue[800]),
                title: Text('Share on Facebook'),
                onTap: () async {
                  Get.back();
                  final url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(tabs[currentTabIndex.value].url)}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.blue[400]),
                title: Text('Share on Twitter'),
                onTap: () async {
                  Get.back();
                  final text = Uri.encodeComponent('Check out this summary: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
                  final url = 'https://twitter.com/intent/tweet?text=$text&url=${Uri.encodeComponent(tabs[currentTabIndex.value].url)}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.green),
                title: Text('Share on WhatsApp'),
                onTap: () async {
                  Get.back();
                  final text = Uri.encodeComponent('Check out this summary: ${content.substring(0, content.length > 100 ? 100 : content.length)}... ${tabs[currentTabIndex.value].url}');
                  final url = 'https://wa.me/?text=$text';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.red),
                title: Text('Share via Email'),
                onTap: () async {
                  Get.back();
                  final subject = Uri.encodeComponent('AI Summary - ${tabs[currentTabIndex.value].url}');
                  final body = Uri.encodeComponent('Here is an AI-generated summary:\n\n$content\n\nSource: ${tabs[currentTabIndex.value].url}');
                  final url = 'mailto:?subject=$subject&body=$body';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      Get.snackbar('Error', 'No content to share', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  Future<void> summarizePage() async {
    final currentTab = tabs[currentTabIndex.value];
    isLoading.value = true;
    try {
      print('Current tab index: ${currentTabIndex.value}');
      print('Current tab URL: ${currentTab.url}');
      Get.snackbar(
        'AI Summary', 
        'Generating summary...', 
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      final text = await _webScraper.extractTextFromUrl(currentTab.url);
      print('Extracted text length: ${text.length}');
      if (text.isEmpty || text.length < 10) {
        Get.snackbar(
          'Error', 
          'Could not extract content from this page', 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      final summaryResult = await _aiService.summarizeText(text);
      print('Summary generated: ${summaryResult['summary']}');
      if (summaryResult['summary'] == null || summaryResult['summary'].toString().isEmpty) {
        Get.snackbar(
          'Error', 
          'Failed to generate summary', 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      currentTab.summary = summaryResult['summary'];
      currentTab.translations = {};
      selectedLanguage.value = 'summary';
      tabs.refresh();
      saveTabs();
      Get.snackbar(
        'Success', 
        'AI Summary generated successfully!', 
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      showSummaryPanel.value = true;
    } catch (e) {
      print('Summarization error: $e');
      Get.snackbar(
        'Error', 
        'Failed to generate summary: $e', 
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> downloadFileFromUrl(String url) async {
    try {
      final fileName = url.split('/').last;
      if (fileName.contains('.')) {
        final file = await _downloadService.downloadFile(url, fileName);
        if (file != null) {
          _analytics.logFileDownload(file.type, file.size);
        }
      } else {
        Get.snackbar('Error', 'Invalid file URL');
      }
    } catch (e) {
      _analytics.recordError(e, StackTrace.current);
      Get.snackbar('Error', 'Download failed: $e');
    }
  }
  String getTabTitle(String url) {
    if (url.contains('google.com')) {
      return 'Google';
    } else if (url.contains('w3schools.com')) {
      if (url.contains('python') && url.contains('string')) {
        return 'Python - String Methods';
      } else if (url.contains('python')) {
        return 'Python Tutorial';
      } else {
        return 'W3Schools';
      }
    } else if (url.contains('youtube.com')) {
      return 'YouTube';
    } else if (url.contains('github.com')) {
      return 'GitHub';
    } else if (url.contains('stackoverflow.com')) {
      return 'Stack Overflow';
    } else if (url.contains('facebook.com')) {
      return 'Facebook';
    } else if (url.contains('twitter.com')) {
      return 'Twitter';
    } else if (url.contains('instagram.com')) {
      return 'Instagram';
    } else if (url.contains('linkedin.com')) {
      return 'LinkedIn';
    } else if (url.contains('wikipedia.org')) {
      return 'Wikipedia';
    } else {
      try {
        final uri = Uri.parse(url);
        return uri.host.replaceAll('www.', '').split('.').first.capitalize ?? 'New Tab';
      } catch (e) {
        return 'New Tab';
      }
    }
  }
  void saveTabs() {
    _storage.saveTabs(tabs);
  }
  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }
}
