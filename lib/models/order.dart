import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutDefaults {
  final String name;
  final String email;
  final String phoneNumber;
  final String shippingAddress;

  const CheckoutDefaults({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.shippingAddress,
  });
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String phoneNumber;
  final String shippingAddress;
  final Map<String, int> items;
  final String paymentStatus;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.items,
    required this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? phoneNumber,
    String? shippingAddress,
    Map<String, int>? items,
    String? paymentStatus,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'items': items,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return OrderModel.fromMap(data, id: snapshot.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return OrderModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      shippingAddress: data['shippingAddress'] as String? ?? '',
      items: _decodeItems(data['items']),
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      createdAt: _dateTimeFromDynamic(data['createdAt']),
      updatedAt: _dateTimeFromDynamic(data['updatedAt']),
    );
  }

  static Map<String, int> _decodeItems(dynamic rawItems) {
    if (rawItems is! Map) {
      return {};
    }

    return rawItems.map<String, int>((key, value) {
      return MapEntry(
        key.toString(),
        (value as num?)?.toInt() ?? 0,
      );
    });
  }

  static DateTime? _dateTimeFromDynamic(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
