import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/models/food.dart';

class CartLine {
  final Food food;
  final int quantity;

  const CartLine({
    required this.food,
    required this.quantity,
  });

  CartLine copyWith({
    Food? food,
    int? quantity,
  }) {
    return CartLine(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [];

  String _foodKey(Food food) {
    return '${food.name}|${food.price}|${food.imagePath}|${food.rating}';
  }

  int _lineIndex(Food food) {
    final key = _foodKey(food);
    return state.indexWhere((line) => _foodKey(line.food) == key);
  }

  void addItem(Food food, [int quantity = 1]) {
    if (quantity <= 0) {
      return;
    }

    final index = _lineIndex(food);
    if (index == -1) {
      state = [...state, CartLine(food: food, quantity: quantity)];
      return;
    }

    final updatedCart = List<CartLine>.from(state);
    final currentLine = updatedCart[index];
    updatedCart[index] = currentLine.copyWith(quantity: currentLine.quantity + quantity);
    state = updatedCart;
  }

  void increaseItem(Food food) {
    addItem(food);
  }

  void decreaseItem(Food food) {
    final index = _lineIndex(food);
    if (index == -1) {
      return;
    }

    final updatedCart = List<CartLine>.from(state);
    final currentLine = updatedCart[index];

    if (currentLine.quantity <= 1) {
      updatedCart.removeAt(index);
    } else {
      updatedCart[index] = currentLine.copyWith(quantity: currentLine.quantity - 1);
    }

    state = updatedCart;
  }

  void removeItem(Food food) {
    final index = _lineIndex(food);
    if (index == -1) {
      return;
    }

    final updatedCart = List<CartLine>.from(state);
    updatedCart.removeAt(index);
    state = updatedCart;
  }

  void clearCart() {
    state = [];
  }
}
