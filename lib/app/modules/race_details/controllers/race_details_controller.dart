import 'package:get/get.dart';

class RaceDetailsController extends GetxController {
  final count = 0.obs;
  
  final selectedTab = 0.obs;
  final expandedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
  
  void setTab(int index) => selectedTab.value = index;
  void toggleExpand(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }
}
