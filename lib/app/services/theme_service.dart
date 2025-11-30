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
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey.shade800,
    ),
  );
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, 
      brightness: Brightness.dark,
    ).copyWith(
      surface: Colors.grey.shade800,
      surfaceVariant: Colors.grey.shade700,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.grey.shade300,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade900,
    cardTheme: CardThemeData(
      color: Colors.grey.shade800,
      elevation: 4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade800,
      foregroundColor: Colors.white,
    ),
    textTheme: ThemeData.dark().textTheme.copyWith(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
  );
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.saveSetting('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
