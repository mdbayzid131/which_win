import 'package:get/get.dart';
import '../controllers/gift_a_friend_controller.dart';

class GiftAFriendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftAFriendController>(
      () => GiftAFriendController(),
    );
  }
}
