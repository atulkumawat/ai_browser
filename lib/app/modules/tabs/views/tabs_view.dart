import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tabs_controller.dart';
class HistoryView extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('History & Tabs'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Clear History'),
                  content: Text('Are you sure you want to clear all browsing history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearHistory();
                        Get.back();
                      },
                      child: Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.loadData();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.activeTabs.isEmpty) {
                  return SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tab, color: Colors.blue.shade600),
                        SizedBox(width: 8),
                        Text(
                          'Active Tabs (${controller.activeTabs.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...controller.activeTabs.map((tab) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: tab.isActive ? 4 : 1,
                      color: tab.isActive ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tab.isActive ? Colors.blue.shade600 : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getTabIcon(tab.url),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          tab.title,
                          style: TextStyle(
                            fontWeight: tab.isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          tab.url,
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tab.isActive)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            SizedBox(width: 8),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'switch',
                                  child: Text('Switch'),
                                ),
                                if (controller.activeTabs.length > 1)
                                  PopupMenuItem(
                                    value: 'close',
                                    child: Text('Close', style: TextStyle(color: Colors.red)),
                                  ),
                              ],
                              onSelected: (value) {
                                if (value == 'switch') {
                                  controller.switchToTab(tab);
                                } else if (value == 'close') {
                                  controller.closeTab(tab.id);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => controller.switchToTab(tab),
                      ),
                    )).toList(),
                    SizedBox(height: 24),
                  ],
                );
              }),
              Row(
                children: [
                  Icon(Icons.history, color: Colors.grey.shade700),
                  SizedBox(width: 8),
                  Text(
                    'Browsing History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Obx(() {
                if (controller.historyItems.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No browsing history', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Start browsing to see history here', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return Column(
                  children: controller.historyItems.map((item) => Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getTabIcon(item.url),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.url,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                controller.getTimeAgo(item.visitedAt),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                              if (item.visitCount > 1) ...[
                                SizedBox(width: 8),
                                Text(
                                  '${item.visitCount} visits',
                                  style: TextStyle(fontSize: 10, color: Colors.blue.shade600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'open',
                            child: Row(
                              children: [
                                Icon(Icons.open_in_browser, size: 16),
                                SizedBox(width: 8),
                                Text('Open'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'open') {
                            controller.openUrl(item.url);
                          } else if (value == 'delete') {
                            controller.deleteHistoryItem(item.url);
                          }
                        },
                      ),
                      onTap: () => controller.openUrl(item.url),
                    ),
                  )).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  IconData _getTabIcon(String url) {
    if (url.contains('google.com')) {
      return Icons.search;
    } else if (url.contains('youtube.com')) {
      return Icons.play_arrow;
    } else if (url.contains('github.com')) {
      return Icons.code;
    } else if (url.contains('stackoverflow.com')) {
      return Icons.help;
    } else if (url.contains('w3schools.com')) {
      return Icons.school;
    } else if (url.contains('facebook.com')) {
      return Icons.facebook;
    } else if (url.contains('twitter.com')) {
      return Icons.alternate_email;
    } else {
      return Icons.web;
    }
  }
}
