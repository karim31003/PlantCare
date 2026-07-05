import '../models/cart_item.dart';
import 'supabase_service.dart';

class CartService {
  CartService._();

  static final _client = SupabaseService.client;
  static const _table = 'cart_items';

  // ─── Fetch cart with product details ──────────────────────────────

  static Future<List<CartItem>> getCartItems() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    final response = await _client
        .from(_table)
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => CartItem.fromMap(e)).toList();
  }

  // ─── Add or increment ─────────────────────────────────────────────

  static Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    // Check if already in cart
    final existing = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Increment quantity
      await _client.from(_table).update({
        'quantity': (existing['quantity'] as int) + quantity,
      }).eq('id', existing['id']);
    } else {
      // Insert new
      await _client.from(_table).insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  // ─── Update quantity ───────────────────────────────────────────────

  static Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    await _client
        .from(_table)
        .update({'quantity': quantity}).eq('id', cartItemId);
  }

  // ─── Remove item ──────────────────────────────────────────────────

  static Future<void> removeItem(String cartItemId) async {
    await _client.from(_table).delete().eq('id', cartItemId);
  }

  // ─── Clear entire cart ────────────────────────────────────────────

  static Future<void> clearCart() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    await _client.from(_table).delete().eq('user_id', userId);
  }
}