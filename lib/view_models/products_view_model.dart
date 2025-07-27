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
  List<Product> _sellerProducts = []; // New: Seller products list
  List<Product> _filteredProducts = []; // New: Filtered products list
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingSellerProducts = false; // New: Loading state for seller products
  bool _isLoadingMoreSellerProducts = false; // New: Loading more state for seller products
  bool _isLoadingFilteredProducts = false; // New: Loading state for filtered products
  bool _isLoadingMoreFilteredProducts = false; // New: Loading more state for filtered products
  String? _error;
  String? _currentCategory;
  String? _currentSearchQuery;
  String? _currentSellerId; // New: Current seller ID
  
  // Filter state
  String? _currentFilterCategoryId;
  double? _currentFilterMinPrice;
  double? _currentFilterMaxPrice;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMoreData = true;
  int _totalCount = 0;
  int _totalPages = 0;
  
  // Seller products pagination state
  int _sellerCurrentPage = 1;
  bool _hasMoreSellerProducts = true;
  int _sellerTotalCount = 0;
  
  // Filtered products pagination state
  int _filteredCurrentPage = 1;
  bool _hasMoreFilteredData = true;
  int _filteredTotalCount = 0;

  ProductsViewModel(this._repository, this._apiClient);

  ProductRepository get repository => _repository;
  ApiClient get apiClient => _apiClient;
  List<Product> get products => _products;
  List<Product> get sellerProducts => _sellerProducts; // New: Getter for seller products
  List<Product> get filteredProducts => _filteredProducts; // New: Getter for filtered products
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingSellerProducts => _isLoadingSellerProducts; // New: Getter for seller products loading
  bool get isLoadingMoreSellerProducts => _isLoadingMoreSellerProducts; // New: Getter for seller products loading more
  bool get isLoadingFilteredProducts => _isLoadingFilteredProducts; // New: Getter for filtered products loading
  bool get isLoadingMoreFilteredProducts => _isLoadingMoreFilteredProducts; // New: Getter for filtered products loading more
  String? get error => _error;
  String? get currentCategory => _currentCategory;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  bool get hasMoreSellerProducts => _hasMoreSellerProducts; // New: Getter for seller products has more
  bool get hasMoreFilteredData => _hasMoreFilteredData; // New: Getter for filtered products has more
  int get totalCount => _totalCount;
  int get filteredTotalCount => _filteredTotalCount; // New: Getter for filtered products total count
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

  // Load seller products with pagination (first page)
  Future<String?> loadSellerProducts(String sellerId) async {
    return await _loadSellerProductsPage(sellerId, 1, reset: true);
  }

  // Load more seller products (next page)
  Future<String?> loadMoreSellerProducts(String sellerId) async {
    if (!_hasMoreSellerProducts || _isLoadingMoreSellerProducts) return null;
    return await _loadSellerProductsPage(sellerId, _sellerCurrentPage + 1, reset: false);
  }

  // Internal method to load seller products with pagination
  Future<String?> _loadSellerProductsPage(String sellerId, int pageNumber, {required bool reset}) async {
    try {
      if (reset) {
        _isLoadingSellerProducts = true;
        _sellerCurrentPage = 1;
        _hasMoreSellerProducts = true;
        _sellerProducts.clear();
        _currentSellerId = sellerId;
      } else {
        _isLoadingMoreSellerProducts = true;
      }
      _error = null;
      notifyListeners();
      
      final response = await _repository.getProductsByUser(sellerId, pageNumber: pageNumber, pageSize: _pageSize);
      final newProducts = response.data ?? [];
      
      // Extract pagination metadata from response
      final metadata = response.metadata;
      if (metadata != null) {
        _sellerCurrentPage = metadata['pageNumber'] ?? pageNumber;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _sellerTotalCount = metadata['totalCount'] ?? 0;
        _hasMoreSellerProducts = metadata['hasNextPage'] ?? false;
      }
      
      if (reset) {
        _sellerProducts = newProducts;
      } else {
        _sellerProducts.addAll(newProducts);
      }
      
      notifyListeners();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      if (reset) {
        _isLoadingSellerProducts = false;
      } else {
        _isLoadingMoreSellerProducts = false;
      }
      notifyListeners();
    }
  }

  // Filter Products Methods
  Future<String?> filterProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await _filterProductsPage(
      1,
      reset: true,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<String?> loadMoreFilteredProducts() async {
    if (!_hasMoreFilteredData || _isLoadingMoreFilteredProducts) return null;
    return await _filterProductsPage(
      _filteredCurrentPage + 1,
      reset: false,
      categoryId: _currentFilterCategoryId,
      minPrice: _currentFilterMinPrice,
      maxPrice: _currentFilterMaxPrice,
    );
  }

  Future<String?> _filterProductsPage(
    int pageNumber, {
    required bool reset,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      if (reset) {
        _isLoadingFilteredProducts = true;
        _filteredCurrentPage = 1;
        _hasMoreFilteredData = true;
        _filteredProducts.clear();
        
        // Store current filter parameters
        _currentFilterCategoryId = categoryId;
        _currentFilterMinPrice = minPrice;
        _currentFilterMaxPrice = maxPrice;
      } else {
        _isLoadingMoreFilteredProducts = true;
      }
      _error = null;
      notifyListeners();

      final response = await _repository.filterProducts(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );
      
      final newProducts = response.data ?? [];

      final metadata = response.metadata;
      if (metadata != null) {
        _filteredCurrentPage = metadata['pageNumber'] ?? pageNumber;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _filteredTotalCount = metadata['totalCount'] ?? 0;
        _hasMoreFilteredData = metadata['hasNextPage'] ?? false;
      }
      
      if (reset) {
        _filteredProducts = newProducts;
      } else {
        _filteredProducts.addAll(newProducts);
      }
      notifyListeners();
      
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      if (reset) {
        _isLoadingFilteredProducts = false;
      } else {
        _isLoadingMoreFilteredProducts = false;
      }
      notifyListeners();
    }
  }
} 