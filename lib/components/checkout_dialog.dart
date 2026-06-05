import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../theme/colors.dart';

class CheckoutDialog extends StatefulWidget {
  final List<CartLine> cartItems;

  const CheckoutDialog({
    super.key,
    required this.cartItems,
  });

  static Future<OrderModel?> show({
    required BuildContext context,
    required List<CartLine> cartItems,
  }) {
    return showDialog<OrderModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CheckoutDialog(cartItems: cartItems),
    );
  }

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _orderService = OrderService();

  bool _isLoadingDefaults = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDefaults());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    try {
      final defaults = await _orderService.loadCheckoutDefaults();
      if (!mounted) return;
      _nameController.text = defaults.name;
      _emailController.text = defaults.email;
      _phoneController.text = defaults.phoneNumber;
      _addressController.text = defaults.shippingAddress;
    } catch (_) {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      _emailController.text = user?.email ?? '';
      final displayName = user?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        _nameController.text = displayName;
      } else {
        final emailPrefix = user?.email?.split('@').first;
        _nameController.text = (emailPrefix != null && emailPrefix.isNotEmpty)
            ? emailPrefix
            : 'Guest';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDefaults = false;
        });
      }
    }
  }

  double _parsePrice(String price) {
    final normalized = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  double get _totalAmount {
    return widget.cartItems.fold<double>(
      0,
      (sum, line) => sum + (_parsePrice(line.food.price) * line.quantity),
    );
  }

  Map<String, int> _itemsMap() {
    return {
      for (final line in widget.cartItems) line.food.id: line.quantity,
    };
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('No signed-in user found.');
      }

      final order = await _orderService.createOrder(
        userId: user.uid,
        customerName: _nameController.text,
        customerEmail: _emailController.text,
        phoneNumber: _phoneController.text,
        shippingAddress: _addressController.text,
        items: _itemsMap(),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(order);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('StateError: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: secondaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.18), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primaryColor, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: _isLoadingDefaults
              ? SizedBox(
                  height: 260,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.shopping_bag_outlined, color: primaryColor),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'DMSerifDisplay',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context, rootNavigator: true).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: secondaryColor.withValues(alpha: 0.10)),
                          ),
                          child: Column(
                            children: [
                              _summaryRow('Items', widget.cartItems.length.toString()),
                              _summaryRow('Total', '\$${_totalAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: _fieldDecoration(
                            hintText: 'Full name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: _fieldDecoration(
                            hintText: 'Email address',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _fieldDecoration(
                            hintText: 'Phone number',
                            icon: Icons.phone_outlined,
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your phone number.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: _fieldDecoration(
                            hintText: 'Shipping address',
                            icon: Icons.location_on_outlined,
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your shipping address.';
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isSubmitting
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
                                : const Text('Proceed'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
