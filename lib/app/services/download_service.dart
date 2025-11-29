import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_item.dart';
import 'storage_service.dart';
class DownloadService extends GetxService {
  final Dio _dio = Dio();
  final StorageService _storage = Get.find<StorageService>();
  Future<FileItem?> downloadFile(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
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
}
