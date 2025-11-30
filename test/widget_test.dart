import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_browser_app/main.dart';
import 'package:ai_browser_app/app/services/storage_service.dart';
import 'package:ai_browser_app/app/services/theme_service.dart';

void main() {
  group('AI Browser Tests', () {
    testWidgets('App loads successfully', (WidgetTester tester) async {
      Get.testMode = true;
      Get.put(StorageService());
      Get.put(ThemeService());
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Theme service works', (WidgetTester tester) async {
      final themeService = ThemeService();
      expect(themeService.isDarkMode.value, false);
      
      themeService.toggleTheme();
      expect(themeService.isDarkMode.value, true);
    });
  });
}