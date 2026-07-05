import 'package:flutter/material.dart';
import '../../data/models/cart_item.dart';
import '../../data/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final _repository = CartRepository();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(String productId) =>
      _items.any((item) => item.productId == productId);

  int quantityOf(String productId) =>
      _items.firstWhere((item) => item.productId == productId,
          orElse: () => CartItem(
              id: '', userId: '', productId: '', quantity: 0)).quantity;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchCart() async {
    _setLoading(true);
    _error = null;
    try {
      _items = await _repository.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    _error = null;
    try {
      await _repository.addToCart(productId: productId, quantity: quantity);
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    _error = null;
    try {
      if (quantity <= 0) {
        await _repository.removeItem(cartItemId);
      } else {
        await _repository.updateQuantity(
            cartItemId: cartItemId, quantity: quantity);
      }
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    _error = null;
    try {
      await _repository.removeItem(cartItemId);
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart() async {
    _error = null;
    try {
      await _repository.clearCart();
      _items = [];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}