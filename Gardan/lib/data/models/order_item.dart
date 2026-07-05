// lib/data/models/order_item.dart

import 'product.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.product,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        id:        map['id'] as String,
        orderId:   map['order_id'] as String,
        productId: map['product_id'] as String,
        quantity:  map['quantity'] as int,
        unitPrice: (map['unit_price'] as num).toDouble(),
        product:   map['products'] != null
            ? Product.fromMap(map['products'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toInsertMap(String orderId) => {
        'order_id':   orderId,
        'product_id': productId,
        'quantity':   quantity,
        'unit_price': unitPrice,
      };
}
