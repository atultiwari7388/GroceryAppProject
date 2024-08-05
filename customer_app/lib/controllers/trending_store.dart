import 'package:get/get.dart';

class TrendingStoreController extends GetxController {
/*------------------- For image -----------------*/
  final RxString _lowestItem = "".obs;
  String get lowestValue => _lowestItem.value;

  set updateLowestItem(String newValue) {
    _lowestItem.value = newValue;
  }

  /*------------------- For title -----------------*/
  final RxString _lowestTitle = "".obs;
  String get lowestTitleValue => _lowestTitle.value;

  set updateLowestTitle(String newValue) {
    _lowestTitle.value = newValue;
  }
}
