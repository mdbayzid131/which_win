import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedCategory = 'All'.obs;

  final categories = <String>['All', 'Tumu', 'Guvnell', 'Guvnell 2', 'Guvnell 3', 'Guvnell 4'].obs;

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
