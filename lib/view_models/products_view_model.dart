import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../core/api/api_response.dart';
import '../core/api/api_client.dart';
import 'dart:io';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final ApiClient _apiClient;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCategory;

  ProductsViewModel(this._repository, this._apiClient);

  ProductRepository get repository => _repository;
  ApiClient get apiClient => _apiClient;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategory => _currentCategory;

  Future<String?> loadProducts({String? category}) async {
    try {
      _isLoading = true;
      _error = null;
      _currentCategory = category;
      notifyListeners();

      if (category != null) {
        _products = await _repository.getProductsByCategory(category);
      } else {
        _products = await _repository.getAll();
      }
      return null; // Success
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loadMyProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _repository.getMyProducts();
      return null; // Success
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<Product?>> addProduct(Product product, {List<File>? images}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.create(product, images: images);

      if (response.success) {
        await loadProducts(); 
      } else {
        _error = response.message;
      }
      return response;
    } catch (e) {
      print('ProductsViewModel addProduct Exception: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      return ApiResponse(success: false, message: _error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.update(product);
      await loadProducts();
      return 'تم تحديث المنتج بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.delete(id);
      await loadMyProducts();
      return 'تم حذف المنتج بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (query.trim().isEmpty) {
        // If search query is empty, load all products
        await loadProducts();
        return null;
      }

      _products = await _repository.searchProducts(query.trim());
      return null; // Success
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 