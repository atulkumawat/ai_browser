import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../browser/controllers/browser_controller.dart';
import '../../files/controllers/files_controller.dart';
import '../../tabs/controllers/tabs_controller.dart';
import '../../settings/controllers/settings_controller.dart';
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BrowserController>(() => BrowserController());
    Get.lazyPut<FilesController>(() => FilesController());
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
