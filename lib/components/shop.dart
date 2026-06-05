import 'package:sushi_restaurant/models/food.dart';
import 'package:sushi_restaurant/data/menu_catalog.dart';

class Shop {
    // Menu List
    final List<Food> _menuList = menuCatalog;

    List<Food> get menu => _menuList;

}
