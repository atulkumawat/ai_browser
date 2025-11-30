import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../browser/views/browser_view.dart';
import '../../files/views/files_view.dart';
import '../../tabs/views/tabs_view.dart';
import '../../settings/views/settings_view.dart';
class HomeView extends GetView<HomeController> {
  final List<Widget> _pages = [
    BrowserView(),
    FilesView(),
    HistoryView(),
    SettingsView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
