import 'product.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime? createdAt;
  final Product? product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.createdAt,
    this.product,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        id: map['id'],
        userId: map['user_id'],
        productId: map['product_id'],
        quantity: map['quantity'] ?? 1,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
        product:
            map['products'] != null ? Product.fromMap(map['products']) : null,
      );

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'quantity': quantity,
      };

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        userId: userId,
        productId: productId,
        quantity: quantity ?? this.quantity,
        createdAt: createdAt,
        product: product,
      );

  double get totalPrice => (product?.price ?? 0) * quantity;
}