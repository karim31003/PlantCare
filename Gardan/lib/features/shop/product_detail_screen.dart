
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/cart_provider.dart';
import 'package:gardain/presentation/providers/products_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  int _quantity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _product = context.read<ProductsProvider>().products.firstWhere(
          (p) => p.id == widget.productId,
          orElse: () => context
              .read<ProductsProvider>()
              .searchResults
              .firstWhere((p) => p.id == widget.productId),
        );
  }

  String _getCategoryLabel(String category) {
    const labels = {
      'plants': '🌱 Plants',
      'supplements': '🧴 Supplements',
      'fertilizers': '🌾 Fertilizers',
      'care': '🪴 Care',
    };
    return labels[category] ?? category;
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'plants': AppTheme.primaryGreen,
      'supplements': Colors.blue,
      'fertilizers': AppTheme.darkLime,
      'care': Colors.purple,
    };
    return colors[category] ?? AppTheme.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppTheme.backgroundLight, elevation: 0),
        body: const Center(child: Text('Product not found')),
      );
    }

    final categoryColor = _getCategoryColor(product.category);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(product),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(product, categoryColor),
                  const SizedBox(height: 12),
                  _buildTitle(product),
                  const SizedBox(height: 20),
                  _buildPriceAndQuantity(product),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildDescription(product),
                  const SizedBox(height: 32),
                  _buildAddToCartButton(product),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.go('/shop'),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.oliveGreen, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: product.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.lightLime.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    _buildImagePlaceholder(product.category),
              )
            : _buildImagePlaceholder(product.category),
      ),
    );
  }

  Widget _buildImagePlaceholder(String category) {
    final icons = {
      'plants': Icons.local_florist_rounded,
      'supplements': Icons.science_rounded,
      'fertilizers': Icons.grass_rounded,
      'care': Icons.spa_rounded,
    };
    return Container(
      color: AppTheme.lightLime.withOpacity(0.2),
      child: Center(
        child: Icon(
          icons[category] ?? Icons.storefront_outlined,
          size: 80,
          color: AppTheme.primaryGreen.withOpacity(0.4),
        ),
      ),
    );
  }

  // ================= CATEGORY BADGE =================

  Widget _buildCategoryBadge(Product product, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        _getCategoryLabel(product.category),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: categoryColor,
        ),
      ),
    );
  }

  // ================= TITLE =================

  Widget _buildTitle(Product product) {
    return Text(
      product.name,
      style: GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppTheme.oliveGreen,
        letterSpacing: -0.5,
        height: 1.2,
      ),
    );
  }

  // ================= PRICE & QUANTITY =================

  Widget _buildPriceAndQuantity(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${(product.price * _quantity).toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              _buildQuantityButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.oliveGreen,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add_rounded,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: AppTheme.oliveGreen),
      ),
    );
  }

  // ================= DIVIDER =================

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
    );
  }

  // ================= DESCRIPTION =================

  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this product',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.oliveGreen,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.description ?? 'No description available.',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ================= ADD TO CART =================

  Widget _buildAddToCartButton(Product product) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
       onPressed: () async {
  final success = await context.read<CartProvider>().addToCart(
    productId: product.id,
    quantity: _quantity,
  );

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🛒 Added to cart!', style: GoogleFonts.outfit()),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  } else {
    final error = context.read<CartProvider>().error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Failed to add to cart')),
    );
  }
},
        icon: const Icon(Icons.shopping_cart_rounded, size: 20),
        label: Text(
          'Add to Cart  •  \$${(product.price * _quantity).toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}