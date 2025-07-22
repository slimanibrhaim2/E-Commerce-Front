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
  bool _isLoadingMore = false;
  String? _error;
  String? _currentCategory;
  String? _currentSearchQuery;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMoreData = true;
  int _totalCount = 0;
  int _totalPages = 0;

  ProductsViewModel(this._repository, this._apiClient);

  ProductRepository get repository => _repository;
  ApiClient get apiClient => _apiClient;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get currentCategory => _currentCategory;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;

  // Load products with pagination (first page)
  Future<String?> loadProducts({String? category}) async {
    return await _loadProductsPage(1, reset: true, category: category);
  }

  // Load more products (next page)
  Future<String?> loadMoreProducts() async {
    if (!_hasMoreData || _isLoadingMore) return null;
    return await _loadProductsPage(_currentPage + 1, reset: false, category: _currentCategory);
  }

  // Internal method to load a specific page
  Future<String?> _loadProductsPage(int pageNumber, {required bool reset, String? category}) async {
    try {
      if (reset) {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _products.clear();
        _currentCategory = category;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();
      
      ApiResponse<List<Product>> response;
      
      if (category != null) {
        response = await _repository.getProductsByCategory(category, pageNumber: pageNumber, pageSize: _pageSize);
      } else {
        response = await _repository.getProducts(pageNumber: pageNumber, pageSize: _pageSize);
      }
      
      final newProducts = response.data ?? [];
      
      // Extract pagination metadata from response
      final metadata = response.metadata;
      if (metadata != null) {
        _currentPage = metadata['pageNumber'] ?? pageNumber;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _totalCount = metadata['totalCount'] ?? 0;
        _hasMoreData = metadata['hasNextPage'] ?? false;
      }
      
      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      
      notifyListeners();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      if (reset) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  // Refresh products (reset to first page)
  Future<String?> refreshProducts() async {
    return await loadProducts(category: _currentCategory);
  }

  Future<String?> loadMyProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.getMyProducts(pageNumber: 1, pageSize: _pageSize);
      _products = response.data ?? [];
      
      // Extract pagination metadata
      final metadata = response.metadata;
      if (metadata != null) {
        _currentPage = metadata['pageNumber'] ?? 1;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _totalCount = metadata['totalCount'] ?? 0;
        _hasMoreData = metadata['hasNextPage'] ?? false;
      }
      
      return response.message;
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
        await refreshProducts(); 
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
      await refreshProducts();
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

  // Search products with pagination (first page)
  Future<String?> searchProducts(String query) async {
    return await _searchProductsPage(query, 1, reset: true);
  }

  // Load more search results (next page)
  Future<String?> loadMoreSearchResults() async {
    if (!_hasMoreData || _isLoadingMore) return null;
    // We need to store the current search query to continue pagination
    // For now, we'll use a simple approach - this could be improved
    return await _searchProductsPage(_currentSearchQuery ?? '', _currentPage + 1, reset: false);
  }

  // Internal method to search products with pagination
  Future<String?> _searchProductsPage(String query, int pageNumber, {required bool reset}) async {
    try {
      if (reset) {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _products.clear();
        _currentSearchQuery = query;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();

      if (query.trim().isEmpty) {
        // If search query is empty, load all products
        if (reset) {
          await loadProducts();
        } else {
          await loadMoreProducts();
        }
        return null;
      }

      final response = await _repository.searchProducts(query.trim(), pageNumber: pageNumber, pageSize: _pageSize);
      final newProducts = response.data ?? [];
      
      // Extract pagination metadata from response
      final metadata = response.metadata;
      if (metadata != null) {
        _currentPage = metadata['pageNumber'] ?? pageNumber;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _totalCount = metadata['totalCount'] ?? 0;
        _hasMoreData = metadata['hasNextPage'] ?? false;
      }
      
      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      
      notifyListeners();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      if (reset) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  Future<ApiResponse<Product?>> editProduct(Product product, {List<File>? images}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.updateProduct(product, images: images);

      if (response.success) {
        await refreshProducts(); 
      } else {
        _error = response.message;
      }
      return response;
    } catch (e) {
      print('ProductsViewModel editProduct Exception: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      return ApiResponse(success: false, message: _error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 