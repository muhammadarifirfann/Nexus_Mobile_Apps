import 'package:get/get.dart';

import '../controllers/loading_screen_controller.dart';

class LoadingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoadingScreenController>(
      () => LoadingScreenController(),
    );
  }
}
