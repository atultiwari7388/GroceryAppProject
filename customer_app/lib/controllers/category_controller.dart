import 'package:get/get.dart';

class CategoryController extends GetxController {
/*------------------- For image -----------------*/
  final RxString _category = "".obs;
  String get categoryValue => _category.value;

  set updateCategory(String newValue) {
    _category.value = newValue;
  }

  /*------------------- For title -----------------*/
  final RxString _categoryTitle = "".obs;
  String get categoryTitleValue => _categoryTitle.value;

  set updateCategoryTitle(String newValue) {
    _categoryTitle.value = newValue;
  }
}
