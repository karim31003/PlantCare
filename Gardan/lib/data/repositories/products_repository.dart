// lib/data/repositories/products_repository.dart

import '../models/product.dart';
import '../services/products_service.dart';

class ProductsRepository {
  Future<List<Product>> getProducts() async {
    try {
      return await ProductsService.getProducts();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await ProductsService.getProductsByCategory(category);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      return await ProductsService.getProductById(productId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      return await ProductsService.searchProducts(query);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('network')) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong with the shop. Please try again.';
  }
}