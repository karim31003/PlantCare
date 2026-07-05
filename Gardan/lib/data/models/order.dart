// lib/data/models/order.dart

import 'order_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:        return 'Order Placed';
      case OrderStatus.confirmed:      return 'Confirmed';
      case OrderStatus.preparing:      return 'Preparing';
      case OrderStatus.shipped:        return 'Shipped';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered:      return 'Delivered';
      case OrderStatus.cancelled:      return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'We received your order and are reviewing it.';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed and is being processed.';
      case OrderStatus.preparing:
        return 'Your items are being packed and prepared.';
      case OrderStatus.shipped:
        return 'Your order has left the warehouse and is on its way.';
      case OrderStatus.outForDelivery:
        return 'Your order is out for delivery. Expect it today!';
      case OrderStatus.delivered:
        return 'Your order has been delivered. Enjoy!';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled.';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  int get step {
    switch (this) {
      case OrderStatus.pending:        return 0;
      case OrderStatus.confirmed:      return 1;
      case OrderStatus.preparing:      return 2;
      case OrderStatus.shipped:        return 3;
      case OrderStatus.outForDelivery: return 4;
      case OrderStatus.delivered:      return 5;
      case OrderStatus.cancelled:      return -1;
    }
  }
}

class Order {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String city;
  final String? state;
  final String? zip;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    this.state,
    this.zip,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'] as List<dynamic>?;

    return Order(
      id:            map['id'] as String,
      userId:        map['user_id'] as String,
      status:        OrderStatus.fromString(map['status'] as String),
      totalAmount:   (map['total_amount'] as num).toDouble(),
      fullName:      map['full_name'] as String,
      phone:         map['phone'] as String,
      streetAddress: map['street_address'] as String,
      city:          map['city'] as String,
      state:         map['state'] as String?,
      zip:           map['zip'] as String?,
      notes:         map['notes'] as String?,
      createdAt:     DateTime.parse(map['created_at'] as String),
      updatedAt:     map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      items: rawItems != null
          ? rawItems
              .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'user_id':        userId,
        'status':         status.name,
        'total_amount':   totalAmount,
        'full_name':      fullName,
        'phone':          phone,
        'street_address': streetAddress,
        'city':           city,
        'state':          state,
        'zip':            zip,
        'notes':          notes,
      };

  String get shortId => id.substring(0, 8).toUpperCase();

  String get fullAddress {
    final parts = [streetAddress, city];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zip != null && zip!.isNotEmpty) parts.add(zip!);
    return parts.join(', ');
  }

  Order copyWith({OrderStatus? status}) => Order(
        id:            id,
        userId:        userId,
        status:        status ?? this.status,
        totalAmount:   totalAmount,
        fullName:      fullName,
        phone:         phone,
        streetAddress: streetAddress,
        city:          city,
        state:         this.state,
        zip:           this.zip,
        notes:         this.notes,
        createdAt:     createdAt,
        updatedAt:     updatedAt,
        items:         items,
      );
}
