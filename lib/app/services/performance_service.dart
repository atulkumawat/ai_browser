import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
class PerformanceService extends GetxService {
  var currentFPS = 0.0.obs;
  var frameCount = 0;
  var lastTimestamp = Duration.zero;
  @override
  void onInit() {
    super.onInit();
    _startFPSMonitoring();
  }
  void _startFPSMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      frameCount++;
      if (lastTimestamp == Duration.zero) {
        lastTimestamp = timeStamp;
        return;
      }
      final elapsed = timeStamp - lastTimestamp;
      if (elapsed.inMilliseconds >= 1000) {
        currentFPS.value = frameCount / (elapsed.inMilliseconds / 1000);
        frameCount = 0;
        lastTimestamp = timeStamp;
      }
    });
  }
  void logPerformanceMetric(String action, Duration duration) {
    print('Performance: $action took ${duration.inMilliseconds}ms');
  }
}
