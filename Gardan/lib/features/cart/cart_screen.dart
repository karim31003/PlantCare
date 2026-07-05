// lib/features/cart/cart_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  Future<void> _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cart',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('Remove all items from your cart?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear',
                style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CartProvider>().clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        backgroundColor: AppTheme.oliveGreen,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/shop'),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        // Isolated App Bar Title
        title: const _CartAppBarTitle(),
        // Isolated App Bar Actions
        actions: [_CartAppBarActions(onClear: _clearCart)],
      ),
      body: const _CartBody(),
    );
  }
}

// ================= ISOLATED APP BAR COMPONENTS =================

class _CartAppBarTitle extends StatelessWidget {
  const _CartAppBarTitle();

  @override
  Widget build(BuildContext context) {
    // Only rebuilds the title if the item count changes
    final itemCount = context.select<CartProvider, int>((p) => p.itemCount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shopping Cart',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (itemCount > 0)
          Text(
            '$itemCount item${itemCount == 1 ? '' : 's'}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
      ],
    );
  }
}

class _CartAppBarActions extends StatelessWidget {
  final VoidCallback onClear;
  const _CartAppBarActions({required this.onClear});

  @override
  Widget build(BuildContext context) {
    // Only rebuilds if the cart transitions between empty and not empty
    final hasItems = context.select<CartProvider, bool>((p) => p.items.isNotEmpty);
    
    if (!hasItems) return const SizedBox.shrink();
    
    return TextButton(
      onPressed: onClear,
      child: Text(
        'Clear all',
        style: GoogleFonts.outfit(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ================= SMART BODY LAYOUT =================

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<CartProvider, bool>((p) => p.isLoading);
    final isEmpty = context.select<CartProvider, bool>((p) => p.items.isEmpty);

    // Only show the big spinner if we have absolutely no items to show
    if (isLoading && isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (isEmpty) {
      return const _EmptyCartState();
    }

    // Keep the list on screen during updates, just show an overlay indicator
    return Stack(
      children: [
        const _CartContent(),
        if (isLoading)
          const Positioned(
            top: 0, left: 0, right: 0,
            child: LinearProgressIndicator(
              color: AppTheme.primaryGreen,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}

// ================= CART CONTENT =================

class _CartContent extends StatelessWidget {
  const _CartContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // REMOVED: const SliverToBoxAdapter(child: _DeliveryBanner()),
        
        // Scope the list rebuilding strictly to this Sliver
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CartItemWidget(
                    item: cartProvider.items[index],
                    key: ValueKey(cartProvider.items[index].id),
                  ),
                  childCount: cartProvider.items.length,
                ),
              ),
            );
          },
        ),
        
        const SliverToBoxAdapter(child: _TrustBadges()),
        
        // Scope the Order Summary rebuilding strictly to itself
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return SliverToBoxAdapter(
              child: _OrderSummary(cartProvider: cartProvider),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ================= EMPTY STATE =================

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.lightLime.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 56, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.oliveGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add something from the shop!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () => context.go('/shop'),
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: Text('Browse Shop',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ================= ORDER SUMMARY =================

class _OrderSummary extends StatelessWidget {
  final CartProvider cartProvider;
  
  const _OrderSummary({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    final subtotal = cartProvider.totalPrice;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Order Summary',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F1111),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow(
                  'Items (${cartProvider.itemCount})',
                  '\$${subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _summaryRow('Shipping', 'FREE',
                    valueColor: AppTheme.primaryGreen),
                const SizedBox(height: 8),
                _summaryRow('Payment', 'Cash on Delivery',
                    valueColor: AppTheme.oliveGreen),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFE8E8E8)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Total',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen, // Changed to green
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen, // Changed to green
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD814),
                  foregroundColor: const Color(0xFF0F1111),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: Color(0xFFF7CA00), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => context.go('/checkout'),
                child: Text(
                  'Proceed to Checkout',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF565959),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F1111),
          ),
        ),
      ],
    );
  }
}

// ================= TRUST BADGES (Stateless) =================

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _badge(Icons.verified_user_outlined, 'Secure\nCheckout'),
          _badge(Icons.cached_rounded, 'Easy\nReturns'),
          _badge(Icons.support_agent_rounded, '24/7\nSupport'),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: const Color(0xFF565959),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ================= CART ITEM WIDGET =================

class _CartItemWidget extends StatelessWidget {
  final CartItem item;

  const _CartItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    if (product == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _imagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F1111),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.lightLime.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AppTheme.oliveGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen, // Changed to green
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined,
                              size: 13, color: AppTheme.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            'Cash on Delivery',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Simplified Quantity Stepper 
                _QuantityStepper(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Subtotal',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFF565959),
                        ),
                      ),
                      // Access totalPrice directly from the fresh item passed down
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen, // Changed to green
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: AppTheme.lightLime.withOpacity(0.12),
      child: const Icon(Icons.local_florist,
          color: AppTheme.primaryGreen, size: 32),
    );
  }
}

// ================= QUANTITY STEPPER =================

class _QuantityStepper extends StatelessWidget {
  final CartItem item;

  const _QuantityStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD5D9D9), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: item.quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: item.quantity == 1 ? Colors.red : const Color(0xFF565959),
            onTap: () {
              if (item.quantity == 1) {
                context.read<CartProvider>().removeItem(item.id);
              } else {
                context.read<CartProvider>().updateQuantity(
                      cartItemId: item.id,
                      quantity: item.quantity - 1,
                    );
              }
            },
          ),
          Container(width: 1, height: 28, color: const Color(0xFFD5D9D9)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F1111),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFD5D9D9)),
          _qtyButton(
            icon: Icons.add_rounded,
            color: const Color(0xFF565959),
            onTap: () => context.read<CartProvider>().updateQuantity(
                  cartItemId: item.id,
                  quantity: item.quantity + 1,
                ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}