import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/file_item.dart';
import 'storage_service.dart';
import '../modules/browser/controllers/browser_controller.dart';
class DownloadService extends GetxService {
  final Dio _dio = Dio();
  final StorageService _storage = Get.find<StorageService>();
  static final Map<String, String> _globalFileContents = {};
  final Map<String, String> _webFileContents = {};
  Future<FileItem?> downloadFile(String url, String fileName) async {
    try {
      final directory = Directory.systemTemp;
      final filePath = '${directory.path}/$fileName';
      await _dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          Get.snackbar('Downloading', '$progress% completed');
        }
      });
      final file = File(filePath);
      final fileStats = await file.stat();
      final fileType = fileName.split('.').last;
      final fileItem = FileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        path: filePath,
        type: fileType,
        size: fileStats.size,
        downloadedAt: DateTime.now(),
      );
      await _storage.saveFile(fileItem);
      Get.snackbar('Success', 'File downloaded: $fileName');
      return fileItem;
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e');
      return null;
    }
  }

  Future<FileItem?> createPDFFile(String fileName, String content) async {
    try {
      if (kIsWeb) {
        // Web platform - store in memory
        final fileId = 'web_storage_$fileName';
        _webFileContents[fileId] = content;
        _globalFileContents[fileName] = content;
        
        print('Storing content for file: $fileName');
        print('Content length: ${content.length}');
        
        // Also store in browser controller
        try {
          final browserController = Get.find<BrowserController>();
          browserController.fileContent.value = content;
          browserController.fileName.value = fileName;
        } catch (e) {
          print('Browser controller not found during file creation: $e');
        }
        
        final fileItem = FileItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          path: fileId,
          type: fileName.split('.').last,
          size: utf8.encode(content).length,
          downloadedAt: DateTime.now(),
        );
        await _storage.saveFile(fileItem);
        return fileItem;
      } else {
        // Mobile platform - use file system
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsString(content, encoding: utf8);
        
        final fileStats = await file.stat();
        final fileType = fileName.split('.').last;
        final fileItem = FileItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          path: filePath,
          type: fileType,
          size: fileStats.size,
          downloadedAt: DateTime.now(),
        );
        
        await _storage.saveFile(fileItem);
        return fileItem;
      }
    } catch (e) {
      print('Error creating file: $e');
      return null;
    }
  }

  Future<void> openFile(FileItem fileItem) async {
    try {
      print('Opening file: ${fileItem.name}, path: ${fileItem.path}');
      if (kIsWeb) {
        try {
          final browserController = Get.find<BrowserController>();
          
          // Try to get from global storage first
          String? content = _globalFileContents[fileItem.name];
          print('Global file content found for ${fileItem.name}: ${content != null}');
          
          if (content == null) {
            // Try web file contents
            content = _webFileContents[fileItem.path];
            print('Web file content found: ${content != null}');
          }
          
          if (content != null && content.isNotEmpty) {
            print('Showing actual content for: ${fileItem.name}');
            print('Content preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
            browserController.showFileContent(fileItem.name, content);
            Get.snackbar('Success', 'File opened: ${fileItem.name}');
          } else {
            print('No content found for file: ${fileItem.name}');
            // Remove file from storage since content is not available
            await _storage.deleteFile(fileItem.id);
            Get.snackbar('Info', 'File removed: content not available');
          }
        } catch (e) {
          print('Browser controller not found: $e');
          Get.snackbar('Info', 'File accessed: ${fileItem.name}');
        }
      } else {
        final result = await OpenFile.open(fileItem.path);
        if (result.type != ResultType.done) {
          Get.snackbar('Info', 'No app found to open this file type');
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      Get.snackbar('Info', 'File accessed: ${fileItem.name}');
    }
  }

  void _showFileContentDialog(String fileName, String content) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.7,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
