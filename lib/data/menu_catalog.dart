import '../models/food.dart';

const List<Food> menuCatalog = [
  Food(
    id: 'california_roll',
    name: 'California Roll',
    price: '\$12.99',
    imagePath: 'lib/images/sushi_1.png',
    rating: '4.5',
  ),
  Food(
    id: 'spicy_tuna_roll',
    name: 'Spicy Tuna Roll',
    price: '\$14.99',
    imagePath: 'lib/images/sushi_2.png',
    rating: '4.7',
  ),
  Food(
    id: 'salmon_roll',
    name: 'Salmon Roll',
    price: '\$13.99',
    imagePath: 'lib/images/sushi_3.png',
    rating: '4.6',
  ),
  Food(
    id: 'dragon_roll',
    name: 'Dragon Roll',
    price: '\$16.99',
    imagePath: 'lib/images/sushi_4.png',
    rating: '4.8',
  ),
  Food(
    id: 'maki',
    name: 'Maki',
    price: '\$12.99',
    imagePath: 'lib/images/maki.png',
    rating: '4.3',
  ),
];

final Map<String, Food> menuCatalogById = {
  for (final food in menuCatalog) food.id: food,
};

Food? menuItemById(String id) => menuCatalogById[id];
