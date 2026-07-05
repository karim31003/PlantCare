// lib/data/repositories/order_repository.dart

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderRepository {
  Future<Order> placeOrder({
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
    try {
      return await OrderService.placeOrder(
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
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Order>> getMyOrders() async {
    try {
      return await OrderService.getMyOrders();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      return await OrderService.getOrderById(orderId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<Order> watchOrder(String orderId) =>
      OrderService.watchOrder(orderId);

  Future<void> cancelOrder(String orderId) async {
    try {
      await OrderService.cancelOrder(orderId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
