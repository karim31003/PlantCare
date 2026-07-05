// lib/features/orders/order_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_item.dart';
import '../../../presentation/providers/orders_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order    = provider.activeOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0),
      appBar: AppBar(
        backgroundColor: AppTheme.oliveGreen,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: Text(
          'Track Order',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (order != null &&
              order.status == OrderStatus.pending)
            TextButton(
              onPressed: () => _confirmCancel(context, order),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen))
          : order == null
              ? _buildError()
              : _buildContent(order),
    );
  }

  // ═════════════════════ MAIN CONTENT ═════════════════════

  Widget _buildContent(Order order) {
    final isCancelled = order.status == OrderStatus.cancelled;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Top status hero banner ──
        _buildStatusBanner(order),

        const SizedBox(height: 12),

        // ── Tracker stepper ──
        if (!isCancelled)
          _buildTrackerStepper(order)
        else
          _buildCancelledBadge(),

        const SizedBox(height: 12),

        // ── Order header card ──
        _buildOrderHeaderCard(order),

        const SizedBox(height: 12),

        // ── Delivery address ──
        _buildAddressCard(order),

        const SizedBox(height: 12),

        // ── Items ──
        _buildItemsCard(order),

        const SizedBox(height: 12),

        // ── Price breakdown ──
        _buildPriceCard(order),

        const SizedBox(height: 12),

        // ── Payment method ──
        _buildPaymentCard(),

        const SizedBox(height: 24),

        // ── Continue shopping button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => context.go('/shop'),
            child: Text(
              'Continue Shopping',
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ═════════════════════ STATUS BANNER ═════════════════════

  Widget _buildStatusBanner(Order order) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;

    Color bgColor;
    Color iconBg;
    IconData icon;

    if (isCancelled) {
      bgColor = const Color(0xFFFFEBEE);
      iconBg  = const Color(0xFFFFCDD2);
      icon    = Icons.cancel_outlined;
    } else if (isDelivered) {
      bgColor = const Color(0xFFE8F5E9);
      iconBg  = const Color(0xFFC8E6C9);
      icon    = Icons.check_circle_rounded;
    } else {
      bgColor = const Color(0xFFFFF8E1);
      iconBg  = const Color(0xFFFFECB3);
      icon    = Icons.local_shipping_rounded;
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
            child: Icon(icon,
                size: 40,
                color: isCancelled
                    ? Colors.red
                    : isDelivered
                        ? AppTheme.primaryGreen
                        : const Color(0xFFF0A500)),
          ),
          const SizedBox(height: 14),
          Text(
            order.status.label,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F1111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.status.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: const Color(0xFF565959),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Live badge
          if (!isCancelled && !isDelivered)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live Tracking',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═════════════════════ STEPPER ═════════════════════

  static const List<OrderStatus> _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  static const List<IconData> _stepIcons = [
    Icons.receipt_long_rounded,
    Icons.check_circle_outline_rounded,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.delivery_dining_rounded,
    Icons.home_rounded,
  ];

  Widget _buildTrackerStepper(Order order) {
    final currentStep = order.status.step;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Order Progress',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F1111),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_steps.length, (i) {
            final stepStatus = _steps[i];
            final isDone    = currentStep > i;
            final isActive  = currentStep == i;
            final isLast    = i == _steps.length - 1;

            return _buildStepRow(
              icon:     _stepIcons[i],
              label:    stepStatus.label,
              desc:     stepStatus.description,
              isDone:   isDone,
              isActive: isActive,
              isLast:   isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required String label,
    required String desc,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    Color circleColor;
    Color iconColor;
    Color lineColor;

    if (isDone) {
      circleColor = AppTheme.primaryGreen;
      iconColor   = Colors.white;
      lineColor   = AppTheme.primaryGreen;
    } else if (isActive) {
      circleColor = const Color(0xFFFFD814);
      iconColor   = const Color(0xFF0F1111);
      lineColor   = const Color(0xFFE0E0E0);
    } else {
      circleColor = const Color(0xFFF0F2F0);
      iconColor   = const Color(0xFFBDBDBD);
      lineColor   = const Color(0xFFE0E0E0);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: circle + line ──
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD814).withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : Icon(icon, color: iconColor, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ── Right: text ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 24, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isActive || isDone
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isActive || isDone
                          ? const Color(0xFF0F1111)
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF565959),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This order has been cancelled.',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════ ORDER HEADER ═════════════════════

  Widget _buildOrderHeaderCard(Order order) {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _infoRow('Order #', order.shortId,
              valueStyle: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F1111),
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          _infoRow('Placed on',
              _formatDate(order.createdAt)),
          const SizedBox(height: 8),
          _infoRow('Items',
              '${order.items.length} product${order.items.length == 1 ? '' : 's'}'),
        ],
      ),
    );
  }

  // ═════════════════════ ADDRESS ═════════════════════

  Widget _buildAddressCard(Order order) {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('📍 Delivery Address'),
          const SizedBox(height: 12),
          _addrRow(Icons.person_outline_rounded, order.fullName),
          const SizedBox(height: 6),
          _addrRow(Icons.phone_outlined, order.phone),
          const SizedBox(height: 6),
          _addrRow(Icons.home_outlined, order.fullAddress),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _addrRow(Icons.notes_rounded, order.notes!),
          ],
        ],
      ),
    );
  }

  Widget _addrRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: const Color(0xFF0F1111))),
          ),
        ],
      );

  // ═════════════════════ ITEMS ═════════════════════

  Widget _buildItemsCard(Order order) {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('🛒 Items Ordered'),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    final name  = item.product?.name ?? 'Product';
    final price = item.unitPrice;
    final qty   = item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.lightLime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_florist,
                color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F1111))),
                Text('Qty: $qty × \$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF565959))),
              ],
            ),
          ),
          Text(
            '\$${(price * qty).toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB12704),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════ PRICE ═════════════════════

  Widget _buildPriceCard(Order order) {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _priceRow('Subtotal', '\$${order.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _priceRow('Shipping', 'FREE',
              valueColor: AppTheme.primaryGreen),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE8E8E8)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Total',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB12704))),
              Text('\$${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB12704))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF565959))),
          Text(value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F1111),
              )),
        ],
      );

  // ═════════════════════ PAYMENT ═════════════════════

  Widget _buildPaymentCard() {
    return _card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments_outlined,
                color: Color(0xFFF0A500), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Method',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F1111))),
                Text('Cash on Delivery',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF565959))),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryGreen, size: 20),
        ],
      ),
    );
  }

  // ═════════════════════ ERROR STATE ═════════════════════

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 52, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            Text('Order not found',
                style: GoogleFonts.outfit(
                    fontSize: 16, color: const Color(0xFF9CA3AF))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/home'),
              child: Text('Go Home',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  // ═════════════════════ CANCEL CONFIRM ═════════════════════

  Future<void> _confirmCancel(
      BuildContext context, Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Order',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to cancel order #${order.shortId}?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: GoogleFonts.outfit()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Cancel',
                style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<OrdersProvider>().cancelOrder(order.id);
    }
  }

  // ═════════════════════ HELPERS ═════════════════════

  Widget _card({
    required Widget child,
    EdgeInsets? margin,
  }) =>
      Container(
        margin: margin ?? EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F1111),
        ),
      );

  Widget _infoRow(String label, String value,
      {TextStyle? valueStyle}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF565959))),
          Text(value,
              style: valueStyle ??
                  GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F1111))),
        ],
      );

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
