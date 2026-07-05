// lib/presentation/providers/orders_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

class OrdersProvider extends ChangeNotifier {
  final _repo = OrderRepository();

  List<Order> _orders = [];
  Order? _activeOrder;
  bool _isLoading = false;
  bool _isPlacing = false;
  String? _error;
  StreamSubscription<Order>? _trackingSub;

  List<Order> get orders    => _orders;
  Order?      get activeOrder => _activeOrder;
  bool        get isLoading => _isLoading;
  bool        get isPlacing => _isPlacing;
  String?     get error     => _error;

  void clearError() { _error = null; notifyListeners(); }

  // ─── Place Order ─────────────────────────────────────────────────

  Future<Order?> placeOrder({
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
    _isPlacing = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _repo.placeOrder(
        fullName:      fullName,
        phone:         phone,
        streetAddress: streetAddress,
        city:          city,
        state:         state,
        zip:           zip,
        notes:         notes,
        cartItems:     cartItems,
        totalAmount:   totalAmount,
      );
      _orders.insert(0, order);
      _activeOrder = order;
      // Start live tracking
      _startTracking(order.id);
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }

  // ─── Fetch all orders ─────────────────────────────────────────────

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repo.getMyOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Watch a single order (real-time) ────────────────────────────

  void watchOrder(String orderId) {
    _startTracking(orderId);
  }

  void _startTracking(String orderId) {
    _trackingSub?.cancel();
    _trackingSub = _repo.watchOrder(orderId).listen(
      (order) {
        _activeOrder = order;
        // Keep the list updated too
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) _orders[idx] = order;
        notifyListeners();
      },
      onError: (e) {
        // Don't crash, just log — we'll still show last known state
        debugPrint('Order tracking error: $e');
      },
    );
  }

  // ─── Cancel ──────────────────────────────────────────────────────

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _repo.cancelOrder(orderId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Load order by id (e.g. deep link) ───────────────────────────

  Future<void> loadOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final order = await _repo.getOrderById(orderId);
      _activeOrder = order;
      _startTracking(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _trackingSub?.cancel();
    super.dispose();
  }
}
