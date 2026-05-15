import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedCategory = 'All'.obs;

  final categories = <String>['All', 'Tumu', 'Guvnell', 'Guvnell 2', 'Guvnell 3', 'Guvnell 4'].obs;

  final races = [
    {
      'country': 'United Kingdom',
      'flag': 'gb',
      'race': 'Royal Ascot - Gold Cup',
      'isLive': true,
      'racesCount': '1',
    },
    {
      'country': 'Turkey',
      'flag': 'tr',
      'race': 'Istanbul Veliefendi',
      'isLive': false,
      'racesCount': '2/3',
    },
    {
      'country': 'United States',
      'flag': 'us',
      'race': 'Kentucky Derby',
      'isLive': true,
      'racesCount': '4/5',
    },
    {
      'country': 'France',
      'flag': 'fr',
      'race': 'Prix de l\'Arc de Triomphe',
      'isLive': false,
      'racesCount': '1/2',
    },
    {
      'country': 'Japan',
      'flag': 'jp',
      'race': 'Japan Cup',
      'isLive': true,
      'racesCount': '3/4',
    },
    {
      'country': 'Australia',
      'flag': 'au',
      'race': 'Melbourne Cup',
      'isLive': false,
      'racesCount': '2/5',
    },
  ].obs;

  final selectedStatus = 'All'.obs;
  final selectedRegion = 'All'.obs;

  void setStatus(String status) => selectedStatus.value = status;
  void setRegion(String region) => selectedRegion.value = region;

  void resetFilters() {
    selectedStatus.value = 'All';
    selectedRegion.value = 'All';
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
