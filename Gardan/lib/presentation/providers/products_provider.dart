// lib/presentation/providers/products_provider.dart

import 'package:flutter/material.dart';
import 'package:gardain/data/repositories/products_repository.dart';
import '../../data/models/product.dart';

class ProductsProvider extends ChangeNotifier {
  final _repository = ProductsRepository();

  List<Product> _products = [];
  List<Product> _searchResults = [];
  String _selectedCategory = 'all';
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get searchResults => _searchResults;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _setLoading(true);
    _error = null;
    try {
      _products = await _repository.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchByCategory(String category) async {
    _selectedCategory = category;
    _setLoading(true);
    _error = null;
    try {
      if (category == 'all') {
        _products = await _repository.getProducts();
      } else {
        _products = await _repository.getProductsByCategory(category);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _error = null;
    try {
      _searchResults = await _repository.searchProducts(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }
}