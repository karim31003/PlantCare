// lib/data/services/products_service.dart

import '../models/product.dart';
import 'supabase_service.dart';

class ProductsService {
  ProductsService._();

  static final _client = SupabaseService.client;
  static const _table = 'products';

  static Future<List<Product>> getProducts() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => Product.fromMap(e)).toList();
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('category', category)
        .order('name', ascending: true);

    return (response as List).map((e) => Product.fromMap(e)).toList();
  }

  static Future<Product?> getProductById(String productId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', productId)
        .maybeSingle();

    return response != null ? Product.fromMap(response) : null;
  }

  static Future<List<Product>> searchProducts(String query) async {
    final response = await _client
        .from(_table)
        .select()
        .ilike('name', '%$query%')
        .order('name', ascending: true);

    return (response as List).map((e) => Product.fromMap(e)).toList();
  }
}