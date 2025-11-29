import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/browser_controller.dart';
import '../../../services/theme_service.dart';
import '../../../services/performance_service.dart';
import '../../../widgets/fps_monitor.dart';
class BrowserView extends GetView<BrowserController> {
  Widget _buildWebpageContent(String url) {
    if (url.contains('google.com')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text('Google', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.blue)),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Expanded(child: Text('Search Google or type a URL', style: TextStyle(color: Colors.grey.shade600))),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Google Search'),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('I\'m Feeling Lucky'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    } else if (url.contains('w3schools.com')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.green.shade600,
            child: Text('W3Schools', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 16),
          Text('Learn to Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('With the world\'s largest web developer site.'),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HTML Tutorial', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Learn HTML basics and advanced concepts'),
                SizedBox(height: 8),
                Text('CSS Tutorial', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Style your web pages with CSS'),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Website Content', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('This is a simulated webpage showing content from:'),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(url, style: TextStyle(fontFamily: 'monospace')),
          ),
          SizedBox(height: 16),
          Text('Sample Content:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
          SizedBox(height: 12),
          Text('• Navigation menu'),
          Text('• Main content area'),
          Text('• Sidebar with links'),
          Text('• Footer information'),
        ],
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.psychology, size: 24, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('AI Browser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          FPSMonitor(),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.download_rounded, color: Colors.blue.shade600),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Download File'),
                  content: TextField(
                    decoration: InputDecoration(hintText: 'Enter file URL'),
                    onSubmitted: (url) {
                      Get.back();
                      controller.downloadFileFromUrl(url);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.palette_rounded, color: Colors.blue.shade600),
            onPressed: () => Get.find<ThemeService>().toggleTheme(),
          ),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios, size: 18),
                              color: controller.canGoBack() ? Colors.blue.shade600 : Colors.grey.shade400,
                              onPressed: controller.canGoBack() ? controller.goBack : null,
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios, size: 18),
                              color: controller.canGoForward() ? Colors.blue.shade600 : Colors.grey.shade400,
                              onPressed: controller.canGoForward() ? controller.goForward : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: controller.urlController,
                          decoration: InputDecoration(
                            hintText: 'Search or enter URL...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (url) {
                            controller.navigateToUrl(url);
                            controller.tabs.refresh();
                          },
                          onChanged: (url) {
                            if (controller.tabs.isNotEmpty) {
                              controller.tabs[controller.currentTabIndex.value].url = url.startsWith('http') ? url : 'https://$url';
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(Icons.refresh_rounded, size: 20),
                        color: Colors.blue.shade600,
                        onPressed: controller.refreshPage,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.tabs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.tabs.length) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        child: InkWell(
                          onTap: () => controller.addNewTab('https://example.com'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.purple.shade400],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      );
                    }
                    final tab = controller.tabs[index];
                    final isActive = controller.currentTabIndex.value == index;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                      child: InkWell(
                        onTap: () => controller.switchTab(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: BoxConstraints(minWidth: 120, maxWidth: 180),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive ? Colors.blue.shade300 : Colors.grey.shade300,
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: isActive ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ] : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tab.title,
                                  style: TextStyle(
                                    color: isActive ? Colors.grey.shade800 : Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (controller.tabs.length > 1)
                                InkWell(
                                  onTap: () => controller.closeTab(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.tabs.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        final currentTab = controller.tabs[controller.currentTabIndex.value];
        final hasUrl = currentTab.url.isNotEmpty && currentTab.url != 'about:blank';
        final summaryPanelOpen = controller.showSummaryPanel.value;
        return Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(20),
                    child: hasUrl ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder(
                                    duration: Duration(seconds: 2),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blue.shade400, Colors.cyan.shade400],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.web, size: 32, color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Web Content\nSimulation',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'AI-powered analysis',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Obx(() => ElevatedButton(
                                    onPressed: controller.isLoading.value ? null : () async {
                                      await controller.summarizePage();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: controller.isLoading.value ? Colors.grey : Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedRotation(
                                          turns: controller.isLoading.value ? 1.0 : 0.0,
                                          duration: Duration(milliseconds: 1000),
                                          child: Icon(
                                            controller.isLoading.value ? Icons.sync : Icons.auto_awesome, 
                                            size: 16,
                                            color: controller.isLoading.value ? Colors.orange : Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          controller.isLoading.value ? 'Generating...' : 'AI Summary',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Obx(() {
                                          final tabIndex = controller.currentTabIndex.value;
                                          final currentTab = controller.tabs[tabIndex];
                                          return Stack(
                                            children: [
                                              InAppWebView(
                                                key: ValueKey('webview_${currentTab.id}_${currentTab.url}'),
                                                initialUrlRequest: URLRequest(
                                                  url: WebUri(currentTab.url),
                                                ),
                                                initialSettings: InAppWebViewSettings(
                                                  useShouldOverrideUrlLoading: false,
                                                  mediaPlaybackRequiresUserGesture: false,
                                                  allowsInlineMediaPlayback: true,
                                                  javaScriptEnabled: true,
                                                  domStorageEnabled: true,
                                                  userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
                                                ),
                                                onLoadStart: (webController, url) {
                                                  controller.webViewLoading.value = true;
                                                  controller.webViewError.value = false;
                                                  if (url != null) {
                                                    controller.urlController.text = url.toString();
                                                  }
                                                },
                                                onLoadStop: (webController, url) async {
                                                  controller.webViewLoading.value = false;
                                                  if (url != null) {
                                                    final currentTab = controller.tabs[controller.currentTabIndex.value];
                                                    currentTab.url = url.toString();
                                                    currentTab.title = controller.getTabTitle(url.toString());
                                                    controller.tabs.refresh();
                                                  }
                                                },
                                                onReceivedError: (webController, request, error) {
                                                  controller.webViewLoading.value = false;
                                                  controller.webViewError.value = true;
                                                },
                                              ),
                                              Obx(() {
                                                if (controller.webViewLoading.value) {
                                                  return Container(
                                                    color: Colors.white,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color: Colors.blue.shade600,
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            'Loading...',
                                                            style: TextStyle(
                                                              color: Colors.grey.shade600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } else if (controller.webViewError.value) {
                                                  return Container(
                                                    color: Colors.white,
                                                    padding: EdgeInsets.all(20),
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.error_outline,
                                                            size: 48,
                                                            color: Colors.red.shade400,
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            'Cannot load this website',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.grey.shade800,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'This site blocks WebView access',
                                                            style: TextStyle(
                                                              color: Colors.grey.shade600,
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          ElevatedButton.icon(
                                                            onPressed: () async {
                                                              final url = currentTab.url;
                                                              if (await canLaunchUrl(Uri.parse(url))) {
                                                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                              }
                                                            },
                                                            icon: Icon(Icons.open_in_browser, size: 18),
                                                            label: Text('Open in Browser'),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.blue.shade600,
                                                              foregroundColor: Colors.white,
                                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              }),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ) : Column(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder(
                                    duration: Duration(seconds: 2),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blue.shade400, Colors.cyan.shade400],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.web, size: 48, color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Web Content Simulation',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'AI-powered content analysis',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 32),
                                  Obx(() => AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value ? null : () async {
                                        await controller.summarizePage();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: controller.isLoading.value ? Colors.grey : Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedRotation(
                                            turns: controller.isLoading.value ? 1.0 : 0.0,
                                            duration: Duration(milliseconds: 1000),
                                            child: Icon(
                                              controller.isLoading.value ? Icons.sync : Icons.auto_awesome, 
                                              size: 20,
                                              color: controller.isLoading.value ? Colors.orange : Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            controller.isLoading.value ? 'Generating Summary...' : 'Generate AI Summary',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Powered by OpenAI GPT-3.5',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (summaryPanelOpen)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 320,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.blue.shade50.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(-5, 0),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'AI Summary',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => controller.showSummaryPanel.value = false,
                                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                                    tooltip: 'Close Summary',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.language, color: Colors.blue.shade600, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Obx(() => DropdownButton<String>(
                                              value: controller.selectedLanguage.value,
                                              isExpanded: true,
                                              underline: SizedBox(),
                                              items: [
                                                DropdownMenuItem(value: 'summary', child: Text('English')),
                                                DropdownMenuItem(value: 'hindi', child: Text('हिंदी')),
                                                DropdownMenuItem(value: 'spanish', child: Text('Español')),
                                                DropdownMenuItem(value: 'french', child: Text('Français')),
                                              ],
                                              onChanged: (value) {
                                                controller.selectedLanguage.value = value!;
                                                if (value != 'summary') {
                                                  controller.translateToLanguage(value);
                                                }
                                              },
                                            )),
                                          ),
                                          Obx(() => AnimatedContainer(
                                            duration: Duration(milliseconds: 200),
                                            child: IconButton(
                                              icon: AnimatedRotation(
                                                turns: controller.isLoading.value ? 1.0 : 0.0,
                                                duration: Duration(milliseconds: 1000),
                                                child: Icon(
                                                  controller.isLoading.value ? Icons.sync : Icons.translate,
                                                  color: controller.isLoading.value ? Colors.orange : Colors.blue.shade600,
                                                ),
                                              ),
                                              onPressed: () {
                                                if (controller.selectedLanguage.value != 'summary') {
                                                  controller.translateToLanguage(controller.selectedLanguage.value);
                                                }
                                              },
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: Obx(() {
                                        final tabIndex = controller.currentTabIndex.value;
                                        String content = '';
                                        bool isTranslating = false;
                                        if (controller.selectedLanguage.value == 'summary') {
                                          content = controller.tabs.isNotEmpty ? (controller.tabs[tabIndex].summary ?? '') : '';
                                        } else {
                                          final translations = controller.tabs.isNotEmpty ? (controller.tabs[tabIndex].translations ?? {}) : <String, String>{};
                                          final translation = translations[controller.selectedLanguage.value];
                                          if (translation == null || translation.isEmpty) {
                                            isTranslating = controller.isLoading.value;
                                            content = isTranslating ? 'Translating...' : 'Click translate button to get ${controller.selectedLanguage.value} translation';
                                          } else {
                                            content = translation;
                                          }
                                        }
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.blue.shade100),
                                          ),
                                          child: Scrollbar(
                                            thumbVisibility: true,
                                            child: SingleChildScrollView(
                                              physics: AlwaysScrollableScrollPhysics(),
                                              padding: EdgeInsets.all(16),
                                              child: AnimatedDefaultTextStyle(
                                                duration: Duration(milliseconds: 200),
                                                style: TextStyle(
                                                  fontStyle: isTranslating ? FontStyle.italic : FontStyle.normal,
                                                  color: isTranslating ? Colors.grey.shade600 : Colors.grey.shade800,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                                child: Text(content),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: controller.copyContent,
                                            icon: Icon(Icons.copy, size: 18),
                                            label: Text('Copy'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue.shade600,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: controller.shareContent,
                                            icon: Icon(Icons.share, size: 18),
                                            label: Text('Share'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple.shade600,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Obx(() => controller.isLoading.value
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  )
                : SizedBox.shrink()),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.showSummaryPanel.value) {
          return SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: controller.isLoading.value ? null : () async {
            final currentTab = controller.tabs[controller.currentTabIndex.value];
            if (currentTab.summary == null || currentTab.summary!.isEmpty) {
              await controller.summarizePage();
            } else {
              controller.showSummaryPanel.value = true;
            }
          },
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          icon: AnimatedRotation(
            turns: controller.isLoading.value ? 1.0 : 0.0,
            duration: Duration(milliseconds: 1000),
            child: Icon(
              controller.isLoading.value ? Icons.sync : Icons.auto_awesome,
              color: controller.isLoading.value ? Colors.orange : Colors.white,
            ),
          ),
          label: Text(
            controller.isLoading.value ? 'Generating...' : 'AI Summary',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 8,
          tooltip: 'Open AI Summary',
        );
      }),
    );
  }
}
