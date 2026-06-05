import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sushi_restaurant/models/order.dart';
import 'package:sushi_restaurant/pages/order_details_page.dart';
import 'package:sushi_restaurant/services/order_service.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Pending time';
    }

    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Widget _statusChip(String status) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = OrderService();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: Text('No user signed in.'),
            )
          : StreamBuilder<List<OrderModel>>(
              stream: service.watchUserOrders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load orders.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders yet.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _statusChip(order.paymentStatus),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${order.items.length} item(s) - ${_formatDate(order.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DMSerifDisplay',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailsPage(order: order),
                                    ),
                                  );
                                },
                                child: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
