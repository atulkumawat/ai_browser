import 'package:get/get.dart';
class AnalyticsService extends GetxService {
  void logEvent(String name, Map<String, dynamic>? parameters) {
    print('Analytics Event: $name - $parameters');
  }
  void logSummarization(String source, int wordCount) {
    logEvent('summarization_completed', {
      'source': source,
      'word_count': wordCount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  void logFileDownload(String fileType, int fileSize) {
    logEvent('file_downloaded', {
      'file_type': fileType,
      'file_size': fileSize,
    });
  }
  void recordError(dynamic exception, StackTrace? stackTrace) {
    print('Error Recorded: $exception');
    print('Stack Trace: $stackTrace');
  }
  void setUserId(String userId) {
    print('User ID Set: $userId');
  }
}
