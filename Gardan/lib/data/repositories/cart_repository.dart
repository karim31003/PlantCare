import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartRepository {
  Future<List<CartItem>> getCartItems() async {
    try {
      return await CartService.getCartItems();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      await CartService.addToCart(productId: productId, quantity: quantity);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await CartService.updateQuantity(
          cartItemId: cartItemId, quantity: quantity);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      await CartService.removeItem(cartItemId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await CartService.clearCart();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('network')) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong with your cart. Please try again.';
  }
}