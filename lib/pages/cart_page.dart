import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/components/button.dart';
import 'package:sushi_restaurant/components/confirmation_dialog.dart';
import 'package:sushi_restaurant/providers/cart_provider.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  double _parsePrice(String price) {
    final normalized = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: secondaryColor,
      shape: const CircleBorder(),
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 20, height: 20),
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCartLine({
    required WidgetRef ref,
    required CartLine line,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Image.asset(line.food.imagePath, width: 48, height: 48),
        title: Text(line.food.name),
        subtitle: Text(line.food.price),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quantityButton(
              icon: Icons.remove,
              onPressed: () {
                ref.read(cartProvider.notifier).decreaseItem(line.food);
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 28,
              child: Text(
                line.quantity.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            _quantityButton(
              icon: Icons.add,
              onPressed: () {
                ref.read(cartProvider.notifier).increaseItem(line.food);
              },
            ),
            const SizedBox(width: 12),
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(cartProvider.notifier).removeItem(line.food);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = cartItems.fold<double>(
      0,
      (sum, line) => sum + (_parsePrice(line.food.price) * line.quantity),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final line = cartItems[index];
                return _buildCartLine(
                  ref: ref,
                  line: line,
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                        Text(
                          _formatPrice(totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ConfirmationDialog.show(
                            context: context,
                            title: 'Clear cart?',
                            message: 'This will remove all items from your cart.',
                            cancelLabel: 'Cancel',
                            confirmLabel: 'Clear Cart',
                            onConfirm: () {
                              ref.read(cartProvider.notifier).clearCart();
                            },
                          );
                        },
                        child: const Text('Clear Cart'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MyButton(
                      text: 'Checkout',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
