
class Product {
  final String id;
  final String name;
  final String category; // plants / supplements / fertilizers / care
  final String? description;
  final double price;
  final String? imageUrl;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        category: map['category'],
        description: map['description'],
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'],
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      };
}