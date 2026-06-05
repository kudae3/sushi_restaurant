import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/menu_catalog.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CheckoutDefaults> loadCheckoutDefaults() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user found.');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    final latestOrder = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .get();

    final latestOrders = latestOrder.docs
        .map(OrderModel.fromFirestore)
        .toList()
      ..sort((a, b) {
        final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCreated.compareTo(aCreated);
      });
    final latestOrderData = latestOrders.isEmpty ? null : latestOrders.first;

    final email = user.email ?? (userData['email'] as String? ?? '');
    final name = _resolveName(userData, user, email);

    return CheckoutDefaults(
      name: name,
      email: email,
      phoneNumber: latestOrderData?.phoneNumber ?? '',
      shippingAddress: latestOrderData?.shippingAddress ?? '',
    );
  }

  Future<OrderModel> createOrder({
    required String userId,
    required String customerName,
    required String customerEmail,
    required String phoneNumber,
    required String shippingAddress,
    required Map<String, int> items,
  }) async {
    final totalAmount = _calculateTotalAmount(items);
    final docRef = await _firestore.collection('orders').add({
      'userId': userId,
      'customerName': customerName.trim(),
      'customerEmail': customerEmail.trim(),
      'phoneNumber': phoneNumber.trim(),
      'shippingAddress': shippingAddress.trim(),
      'items': items,
      'paymentStatus': 'pending',
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return OrderModel(
      id: docRef.id,
      userId: userId,
      customerName: customerName.trim(),
      customerEmail: customerEmail.trim(),
      phoneNumber: phoneNumber.trim(),
      shippingAddress: shippingAddress.trim(),
      items: items,
      paymentStatus: 'pending',
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) {
            final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
            orders.sort((a, b) {
              final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bCreated.compareTo(aCreated);
            });
            return orders;
          },
        );
  }

  Future<void> markOrderPaid(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'paymentStatus': 'paid',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double _calculateTotalAmount(Map<String, int> items) {
    return items.entries.fold<double>(0, (sum, entry) {
      final food = menuItemById(entry.key);
      if (food == null) {
        return sum;
      }

      final price = _parsePrice(food.price);
      return sum + (price * entry.value);
    });
  }

  double _parsePrice(String price) {
    final normalized = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  String _resolveName(
    Map<String, dynamic> userData,
    User user,
    String email,
  ) {
    final username = userData['username'] as String?;
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }

    final displayName = user.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email.contains('@')) {
      return email.split('@').first.trim();
    }

    return 'Guest';
  }
}
