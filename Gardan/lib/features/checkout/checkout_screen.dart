import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/cart_provider.dart';
import 'package:gardain/presentation/providers/orders_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import 'models/checkout_data.dart';
import 'widgets/address_section.dart';
import 'widgets/order_items_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/place_order_bar.dart';
import 'widgets/success_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = CheckoutControllers();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPlacingOrder = true);

    final cartProvider = context.read<CartProvider>();
    final ordersProvider = context.read<OrdersProvider>();

    final order = await ordersProvider.placeOrder(
      fullName: _controllers.fullNameCtrl.text.trim(),
      phone: _controllers.phoneCtrl.text.trim(),
      streetAddress: _controllers.streetCtrl.text.trim(),
      city: _controllers.cityCtrl.text.trim(),
      state: _controllers.stateCtrl.text.trim(),
      zip: _controllers.zipCtrl.text.trim(),
      notes: _controllers.notesCtrl.text.trim(),
      cartItems: cartProvider.items,
      totalAmount: cartProvider.totalPrice,
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ordersProvider.error ?? 'Failed to place order. Try again.',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await cartProvider.clearCart();
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SuccessDialog(orderId: order.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/cart'),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.oliveGreen,
              size: 18,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.oliveGreen,
              ),
            ),
            Text(
              'Enter your delivery details',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AddressSection(controllers: _controllers),
                  const SizedBox(height: 20),
                  const OrderItemsSection(),
                  const SizedBox(height: 20),
                  const OrderSummarySection(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'By placing your order, you agree to our Terms of Service',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PlaceOrderBar(
        totalAmount: cartProvider.totalPrice,
        isPlacingOrder: _isPlacingOrder,
        onPlaceOrder: _placeOrder,
      ),
    );
  }
}