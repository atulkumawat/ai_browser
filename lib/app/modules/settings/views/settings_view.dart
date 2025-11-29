import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance', Icons.palette),
            Card(
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Enable dark theme'),
                    value: controller.isDarkMode.value,
                    onChanged: (value) => controller.toggleTheme(),
                    secondary: Icon(Icons.dark_mode),
                  )),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('AI Features', Icons.auto_awesome),
            Card(
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Auto Summarize'),
                    subtitle: Text('Automatically summarize pages'),
                    value: controller.autoSummarize.value,
                    onChanged: controller.toggleAutoSummarize,
                    secondary: Icon(Icons.summarize),
                  )),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Privacy', Icons.privacy_tip),
            Card(
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Save Browsing History'),
                    subtitle: Text('Keep track of visited pages'),
                    value: controller.saveHistory.value,
                    onChanged: controller.toggleSaveHistory,
                    secondary: Icon(Icons.history),
                  )),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Storage', Icons.storage),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Cache Size'),
                    subtitle: Obx(() => Text('Currently using ${controller.cacheSize.value}')),
                    trailing: TextButton(
                      onPressed: controller.clearCache,
                      child: Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                    leading: Icon(Icons.cached),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('About', Icons.info),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('About AI Browser'),
                    subtitle: Text('Version 1.0.0'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    leading: Icon(Icons.psychology, color: Colors.blue),
                    onTap: controller.showAbout,
                  ),
                  ListTile(
                    title: Text('Privacy Policy'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    leading: Icon(Icons.policy),
                    onTap: () => Get.snackbar('Info', 'Privacy policy would open here'),
                  ),
                  ListTile(
                    title: Text('Terms of Service'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    leading: Icon(Icons.description),
                    onTap: () => Get.snackbar('Info', 'Terms of service would open here'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    'AI Browser v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Powered by OpenAI GPT-3.5',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
