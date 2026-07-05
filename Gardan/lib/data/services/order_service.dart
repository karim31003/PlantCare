// lib/data/services/order_service.dart

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'supabase_service.dart';

class OrderService {
  OrderService._();

  static final _client  = SupabaseService.client;
  static const _orders  = 'orders';
  static const _oItems  = 'order_items';

  // ─── Place a new order ────────────────────────────────────────────

  /// Creates an order row + all order_item rows in one go.
  /// Returns the saved [Order] with its generated id.
  static Future<Order> placeOrder({
    required String fullName,
    required String phone,
    required String streetAddress,
    required String city,
    String? state,
    String? zip,
    String? notes,
    required List<CartItem> cartItems,
    required double totalAmount,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // 1. Insert the order header
    final orderRow = await _client
        .from(_orders)
        .insert({
          'user_id':        userId,
          'status':         OrderStatus.pending.name,
          'total_amount':   totalAmount,
          'full_name':      fullName,
          'phone':          phone,
          'street_address': streetAddress,
          'city':           city,
          'state':          state,
          'zip':            zip,
          'notes':          notes,
        })
        .select()
        .single();

    final orderId = orderRow['id'] as String;

    // 2. Insert all order items
    final itemRows = cartItems.map((ci) => {
      'order_id':   orderId,
      'product_id': ci.productId,
      'quantity':   ci.quantity,
      'unit_price': ci.product?.price ?? 0.0,
    }).toList();

    await _client.from(_oItems).insert(itemRows);

    // 3. Return the full order
    return getOrderById(orderId);
  }

  // ─── Fetch all orders for current user ───────────────────────────

  static Future<List<Order>> getMyOrders() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
        .from(_orders)
        .select('*, order_items(*, products(*))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Fetch single order by id ─────────────────────────────────────

  static Future<Order> getOrderById(String orderId) async {
    final response = await _client
        .from(_orders)
        .select('*, order_items(*, products(*))')
        .eq('id', orderId)
        .single();

    return Order.fromMap(response as Map<String, dynamic>);
  }

  // ─── Live realtime stream for a single order ──────────────────────

  static Stream<Order> watchOrder(String orderId) {
    // stream() gives us realtime status updates.
    // We then fetch the full order (with items) on every status change.
    return _client
        .from(_orders)
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .asyncMap((rows) async {
          if (rows.isEmpty) throw Exception('Order not found');
          // Re-fetch with joined items so the items list is never empty
          return getOrderById(orderId);
        });
  }

  // ─── Cancel an order (only when still pending) ───────────────────

  static Future<void> cancelOrder(String orderId) async {
    await _client
        .from(_orders)
        .update({'status': OrderStatus.cancelled.name})
        .eq('id', orderId);
  }
}
