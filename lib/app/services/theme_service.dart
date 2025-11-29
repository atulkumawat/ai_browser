import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';
class ThemeService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  var isDarkMode = false.obs;
  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.getSetting('isDarkMode') ?? false;
  }
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    brightness: Brightness.light,
  );
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    brightness: Brightness.dark,
  );
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.saveSetting('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
