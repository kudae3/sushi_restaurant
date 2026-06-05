import 'package:flutter/material.dart';
import 'package:sushi_restaurant/components/confirmation_dialog.dart';
import 'package:sushi_restaurant/data/menu_catalog.dart';
import 'package:sushi_restaurant/models/order.dart';
import 'package:sushi_restaurant/services/order_service.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderModel _order;
  final OrderService _orderService = OrderService();
  bool _isUpdatingPayment = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Pending time';
    }

    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  double _parsePrice(String price) {
    final normalized = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  double get _computedTotal {
    return _order.items.entries.fold<double>(0, (sum, entry) {
      final food = menuItemById(entry.key);
      if (food == null) {
        return sum;
      }

      return sum + (_parsePrice(food.price) * entry.value);
    });
  }

  Color get _statusColor {
    return _order.paymentStatus == 'paid' ? Colors.green : Colors.orange;
  }

  Future<void> _makePayment() async {
    if (_order.paymentStatus == 'paid' || _isUpdatingPayment) {
      return;
    }

    await ConfirmationDialog.show(
      context: context,
      title: 'Make payment?',
      message: 'Confirm to mark this order as paid.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Pay Now',
      onConfirm: () async {
        setState(() {
          _isUpdatingPayment = true;
        });
        try {
          await _orderService.markOrderPaid(_order.id);
          if (!mounted) return;
          setState(() {
            _order = _order.copyWith(
              paymentStatus: 'paid',
              updatedAt: DateTime.now(),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment status updated.')),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update payment status.')),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isUpdatingPayment = false;
            });
          }
        }
      },
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _order.paymentStatus.toUpperCase(),
        style: TextStyle(
          color: _statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _itemTile(String productId, int quantity) {
    final food = menuItemById(productId);
    final itemTotal = food == null ? 0 : _parsePrice(food.price) * quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: food == null
            ? const Icon(Icons.fastfood_outlined)
            : Image.asset(food.imagePath, width: 48, height: 48),
        title: Text(food?.name ?? 'Unknown item'),
        subtitle: Text('Qty: $quantity'),
        trailing: Text(
          '\$${itemTotal.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _order.paymentStatus == 'paid';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2F2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${_order.id.substring(0, _order.id.length > 8 ? 8 : _order.id.length).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                      ),
                      _statusChip(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoTile(
                    label: 'Customer name',
                    value: _order.customerName,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    label: 'Email',
                    value: _order.customerEmail,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    label: 'Phone number',
                    value: _order.phoneNumber,
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    label: 'Shipping address',
                    value: _order.shippingAddress,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    label: 'Created at',
                    value: _formatDate(_order.createdAt),
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    label: 'Total amount',
                    value: '\$${_computedTotal.toStringAsFixed(2)}',
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'DMSerifDisplay',
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            ..._order.items.entries.map(
              (entry) => _itemTile(entry.key, entry.value),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isPaid || _isUpdatingPayment ? null : _makePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isUpdatingPayment
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      )
                    : Text(isPaid ? 'Paid' : 'Make Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
