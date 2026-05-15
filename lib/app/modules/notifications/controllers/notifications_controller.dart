import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final count = 0.obs;
  
  final notifications = [
    {
      'title': 'Match Starting Soon',
      'description': 'Raja Casablanca vs Wydad starts in 30 minutes',
      'time': '2 min ago',
      'type': 'match',
    },
    {
      'title': 'Prediction Update',
      'description': 'New AI prediction available for tonight\'s matches',
      'time': '1 hour ago',
      'type': 'prediction',
    },
    {
      'title': 'Subscription Reminder',
      'description': 'Your subscription expires in 3 days',
      'time': '2 hours ago',
      'type': 'subscription',
    },
    {
      'title': 'Big Win Alert!',
      'description': 'Venom won the race at Kentucky with 12/1 odds!',
      'time': '5 hours ago',
      'type': 'alert',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void increment() => count.value++;
}
