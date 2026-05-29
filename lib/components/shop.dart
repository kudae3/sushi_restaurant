import 'package:sushi_restaurant/models/food.dart';

class Shop {
    // Menu List
    final List<Food> _menuList = [
      Food(name: 'California Roll', price: '\$12.99', imagePath: 'lib/images/sushi_1.png', rating: '4.5'),
      Food(name: 'Spicy Tuna Roll', price: '\$14.99', imagePath: 'lib/images/sushi_2.png', rating: '4.7'),
      Food(name: 'Salmon Roll', price: '\$13.99', imagePath: 'lib/images/sushi_3.png', rating: '4.6'),
      Food(name: 'Dragon Roll', price: '\$16.99', imagePath: 'lib/images/sushi_4.png', rating: '4.8'),
      Food(name: 'Maki', price: '\$12.99', imagePath: 'lib/images/maki.png', rating: '4.3'),
    ];

    List<Food> get menu => _menuList;

}