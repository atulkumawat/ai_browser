import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/files_controller.dart';
import '../../../models/file_item.dart';
class FilesView extends GetView<FilesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: controller.pickFile,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No files yet', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Tap + to add files'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.files.length,
          itemBuilder: (context, index) {
            final file = controller.files[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _getFileIcon(file.type),
                title: Text(file.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_formatFileSize(file.size)} • ${file.type.toUpperCase()}'),
                    Text('${file.downloadedAt.day}/${file.downloadedAt.month}/${file.downloadedAt.year}'),
                    if (file.summary != null)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: Colors.green.shade700),
                            SizedBox(width: 4),
                            Text('AI Summary Available', style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: Obx(() {
                  if (controller.loadingFileId.value == file.id) {
                    return Container(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'summarize',
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 8),
                            Text('Summarize'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'summarize') {
                        controller.summarizeFile(file);
                      } else if (value == 'delete') {
                        controller.deleteFile(file.id);
                      }
                    },
                  );
                }),
                onTap: () => controller.openFile(file),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.pickFile,
        child: Icon(Icons.add),
      ),
    );
  }
  Widget _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'docx':
      case 'doc':
        return Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xlsx':
      case 'xls':
        return Icon(Icons.table_chart, color: Colors.green, size: 32);
      case 'pptx':
      case 'ppt':
        return Icon(Icons.slideshow, color: Colors.orange, size: 32);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey, size: 32);
    }
  }
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
