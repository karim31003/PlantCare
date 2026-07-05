// lib/features/profile/presentation/my_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/order.dart';
import '../../../presentation/providers/orders_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        backgroundColor: AppTheme.oliveGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Your Orders',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : provider.orders.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () =>
                      context.read<OrdersProvider>().fetchOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) =>
                        _buildOrderCard(ctx, provider.orders[i]),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: order id + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.shortId}',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F1111),
                        letterSpacing: 1)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status.label,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),

            // Date & items
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF878787)),
                const SizedBox(width: 6),
                Text(_formatDate(order.createdAt),
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: const Color(0xFF878787))),
                const Spacer(),
                const Icon(Icons.inventory_2_outlined,
                    size: 13, color: Color(0xFF878787)),
                const SizedBox(width: 6),
                Text(
                  '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: const Color(0xFF878787)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Items names preview
            if (order.items.isNotEmpty)
              Text(
                order.items
                    .take(2)
                    .map((e) => e.product?.name ?? 'Product')
                    .join(', ') +
                    (order.items.length > 2 ? '...' : ''),
                style: GoogleFonts.outfit(
                    fontSize: 13, color: const Color(0xFF565959)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Total + view button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: const Color(0xFF878787))),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB12704)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => context.push('/orders/${order.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: Text('Track Order',
                      style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 56, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 20),
          Text('No orders yet',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F1111))),
          const SizedBox(height: 8),
          Text('Your order history will appear here',
              style: GoogleFonts.outfit(
                  fontSize: 14, color: const Color(0xFF878787))),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.go('/shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
            ),
            child: Text('Start Shopping',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:        return const Color(0xFFF0A500);
      case OrderStatus.confirmed:      return const Color(0xFF2196F3);
      case OrderStatus.preparing:      return const Color(0xFF9C27B0);
      case OrderStatus.shipped:        return const Color(0xFF00BCD4);
      case OrderStatus.outForDelivery: return const Color(0xFFFF5722);
      case OrderStatus.delivered:      return AppTheme.primaryGreen;
      case OrderStatus.cancelled:      return Colors.red;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
