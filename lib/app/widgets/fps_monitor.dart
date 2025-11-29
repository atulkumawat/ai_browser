import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/performance_service.dart';
class FPSMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fps = Get.find<PerformanceService>().currentFPS.value;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: fps > 50 ? Colors.green : fps > 30 ? Colors.orange : Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${fps.toStringAsFixed(0)}fps',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
    });
  }
}
