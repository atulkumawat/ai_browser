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
  var showDownloads = false.obs;
  var fileContent = ''.obs;
  var fileName = ''.obs;
  var isSearchMode = false.obs;
  var searchResults = ''.obs;
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
  void navigateToUrl(String input) {
    // Check if input is URL or search text
    if (_isUrl(input)) {
      // It's a URL - show webview
      isSearchMode.value = false;
      String url = input;
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
    } else {
      // It's a search text - show AI content
      _performSearch(input);
    }
  }

  bool _isUrl(String input) {
    return input.contains('.') && 
           (input.startsWith('http') || 
            input.contains('.com') || 
            input.contains('.org') || 
            input.contains('.net') || 
            input.contains('.edu') ||
            input.contains('www.'));
  }

  Future<void> _performSearch(String query) async {
    try {
      isSearchMode.value = true;
      isLoading.value = true;
      
      // Generate AI response for the search query
      final response = await _aiService.generateSearchResponse(query);
      searchResults.value = response;
      
      // Update current tab
      final currentTab = tabs[currentTabIndex.value];
      currentTab.title = 'Search: $query';
      currentTab.url = 'search://$query';
      urlController.text = query;
      
      saveTabs();
    } catch (e) {
      print('Search failed: $e');
      searchResults.value = 'Search failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
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
    } else if (selectedLanguage.value == 'file') {
      content = fileContent.value;
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
  Future<void> downloadAsPDF() async {
    String content = '';
    if (selectedLanguage.value == 'summary') {
      content = currentSummary;
    } else {
      content = currentTranslations[selectedLanguage.value] ?? '';
    }
    
    if (content.isNotEmpty) {
      try {
        Get.back(); // Close dialog first
        
        Get.snackbar(
          'Processing', 
          'Creating PDF...',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        
        final currentTab = tabs[currentTabIndex.value];
        final fileName = 'AI_Summary_${DateTime.now().millisecondsSinceEpoch}.txt';
        
        // Create PDF content
        final pdfContent = '''AI Summary Report

Website: ${currentTab.title}
URL: ${currentTab.url}
Generated: ${DateTime.now().toString().split('.')[0]}
Language: ${selectedLanguage.value == 'summary' ? 'English' : selectedLanguage.value}

--- SUMMARY ---

$content

--- END OF SUMMARY ---

Generated by AI Browser App
Powered by OpenAI GPT-3.5''';
        
        final file = await _downloadService.createPDFFile(fileName, pdfContent);
        if (file != null) {
          // Store content for later access
          fileContent.value = pdfContent;
          this.fileName.value = fileName;
          
          Get.snackbar(
            'Success', 
            'File downloaded: $fileName',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            mainButton: TextButton(
              onPressed: () => _downloadService.openFile(file),
              child: Text('Open', style: TextStyle(color: Colors.white)),
            ),
          );
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to create file: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.back();
      Get.snackbar('Error', 'No content to download', backgroundColor: Colors.red, colorText: Colors.white);
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
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.share, color: Theme.of(Get.context!).colorScheme.primary, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Share Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.copy, color: Colors.blue.shade700, size: 20),
                        ),
                        title: Text('Copy to Clipboard'),
                        subtitle: Text('Copy summary text'),
                        onTap: () {
                          Get.back();
                          copyContent();
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 20),
                        ),
                        title: Text('Download as PDF'),
                        subtitle: Text('Save summary as PDF file'),
                        onTap: downloadAsPDF,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Share on Social Media',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      icon: Icons.facebook,
                      color: Colors.blue.shade800,
                      label: 'Facebook',
                      onTap: () async {
                        Get.back();
                        final url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(tabs[currentTabIndex.value].url)}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _buildSocialButton(
                      icon: Icons.alternate_email,
                      color: Colors.blue.shade400,
                      label: 'Twitter',
                      onTap: () async {
                        Get.back();
                        final text = Uri.encodeComponent('Check out this AI summary: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
                        final url = 'https://twitter.com/intent/tweet?text=$text&url=${Uri.encodeComponent(tabs[currentTabIndex.value].url)}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _buildSocialButton(
                      icon: Icons.chat,
                      color: Colors.green.shade600,
                      label: 'WhatsApp',
                      onTap: () async {
                        Get.back();
                        final text = Uri.encodeComponent('Check out this AI summary: ${content.substring(0, content.length > 100 ? 100 : content.length)}... ${tabs[currentTabIndex.value].url}');
                        final url = 'https://wa.me/?text=$text';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _buildSocialButton(
                      icon: Icons.email,
                      color: Colors.red.shade600,
                      label: 'Email',
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
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      Get.snackbar('Error', 'No content to share', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
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
  void showFileContent(String name, String content) {
    fileName.value = name;
    fileContent.value = content;
    selectedLanguage.value = 'file';
    showSummaryPanel.value = true;
  }

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }
}
