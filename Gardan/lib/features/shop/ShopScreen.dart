import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gardain/presentation/providers/cart_provider.dart';
import 'package:gardain/presentation/providers/products_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/product.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'value': 'all', 'icon': Icons.grid_view_rounded},
    {'label': 'Plants', 'value': 'plants', 'icon': Icons.local_florist_rounded},
    {'label': 'Supplements', 'value': 'supplements', 'icon': Icons.science_rounded},
    {'label': 'Fertilizers', 'value': 'fertilizers', 'icon': Icons.grass_rounded},
    {'label': 'Care', 'value': 'care', 'icon': Icons.spa_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      context.read<ProductsProvider>().fetchProducts();
    } else {
      setState(() => _isSearching = true);
      context.read<ProductsProvider>().searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plant Shop', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.oliveGreen)),
            Text('Everything your plants need', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.oliveGreen.withOpacity(0.6))),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/cart'),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                ),
                child: const Icon(Icons.shopping_cart_rounded, color: AppTheme.oliveGreen, size: 22),
              ),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.itemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  // ================= SEARCH =================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.oliveGreen),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: GoogleFonts.outfit(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFF9CA3AF), size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF9CA3AF), size: 20),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY TABS =================

  Widget _buildCategoryTabs() {
    final selectedCategory =
        context.watch<ProductsProvider>().selectedCategory;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat['value'];

          return GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() => _isSearching = false);
              context
                  .read<ProductsProvider>()
                  .fetchByCategory(cat['value'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= PRODUCT GRID =================

  Widget _buildProductGrid() {
    final provider = context.watch<ProductsProvider>();
    final products =
        _isSearching ? provider.searchResults : provider.products;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ProductsProvider>().fetchProducts(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Retry',
                  style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront_outlined,
                size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? 'No products found'
                  : 'No products in this category',
              style: GoogleFonts.outfit(
                color: const Color(0xFF9CA3AF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  // ================= PRODUCT CARD =================

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => context.go('/shop/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightLime.withOpacity(0.15),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildProductPlaceholder(product.category),
                      )
                    : _buildProductPlaceholder(product.category),
              ),
            ),
      
            // ── Info ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.oliveGreen,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder(String category) {
    final icons = {
      'plants': Icons.local_florist_rounded,
      'supplements': Icons.science_rounded,
      'fertilizers': Icons.grass_rounded,
      'care': Icons.spa_rounded,
    };

    return Container(
      color: AppTheme.lightLime.withOpacity(0.15),
      child: Center(
        child: Icon(
          icons[category] ?? Icons.storefront_outlined,
          size: 48,
          color: AppTheme.primaryGreen.withOpacity(0.4),
        ),
      ),
    );
  }
}