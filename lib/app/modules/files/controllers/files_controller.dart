import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/file_item.dart';
import '../../../services/storage_service.dart';
import '../../../services/ai_service.dart';
import '../../../services/document_processor.dart';
class FilesController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AIService _aiService = Get.put(AIService());
  final DocumentProcessor _docProcessor = Get.put(DocumentProcessor());
  var files = <FileItem>[].obs;
  var isLoading = false.obs;
  var loadingFileId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    print('FilesController initialized');
    loadFiles();
  }
  void loadFiles() {
    print('Loading files from storage...');
    final loadedFiles = _storage.getFiles();
    print('Loaded ${loadedFiles.length} files from storage');
    files.value = loadedFiles;
    print('Files observable updated with ${files.length} files');
  }
  Future<void> pickFile() async {
    try {
      print('Starting file picker...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('Selected file: ${file.name}');
        final fileItem = FileItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          path: file.name, // Use name as path for web
          type: file.extension ?? 'unknown',
          size: file.size,
          downloadedAt: DateTime.now(),
        );
        await _storage.saveFile(fileItem);
        loadFiles();
        Get.snackbar('Success', 'File added: ${file.name}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }
  Future<void> summarizeFile(FileItem file) async {
    try {
      loadingFileId.value = file.id;
      final text = await _docProcessor.extractTextFromFile(file.path, file.type);
      final summaryResult = await _aiService.summarizeText(text);
      file.summary = summaryResult['summary'];
      await _storage.saveFile(file);
      loadFiles();
      Get.snackbar('Success', 'File summarized successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to summarize: $e');
    } finally {
      loadingFileId.value = '';
    }
  }
  void openFile(FileItem file) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(child: Text(file.name, style: TextStyle(fontSize: 16))),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Type: ${file.type.toUpperCase()}'),
                      Text('Size: ${_formatFileSize(file.size)}'),
                      Text('Date: ${file.downloadedAt.day}/${file.downloadedAt.month}/${file.downloadedAt.year}'),
                    ],
                  ),
                ),
              ),
              if (file.summary != null) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(12),
                    child: Text(file.summary!, style: TextStyle(height: 1.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (file.summary == null)
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                summarizeFile(file);
              },
              icon: Icon(Icons.auto_awesome, size: 16),
              label: Text('Generate Summary'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  Future<void> deleteFile(String id) async {
    await _storage.deleteFile(id);
    loadFiles();
    Get.snackbar('Success', 'File deleted');
  }
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
