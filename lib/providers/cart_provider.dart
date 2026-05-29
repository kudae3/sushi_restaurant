import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/models/food.dart';

final cartProvider = NotifierProvider<CartNotifier, List<Food>>(CartNotifier.new);

class CartNotifier extends Notifier<List<Food>> {
  @override
  List<Food> build() => [];

  void addItem(Food food) {
    state = [...state, food];
  }

  void removeItem(Food food) {
    final updatedCart = List<Food>.from(state);
    updatedCart.remove(food);
    state = updatedCart;
  }

  void clearCart() {
    state = [];
  }
}
