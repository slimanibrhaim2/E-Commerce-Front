import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';
import '../core/api/api_client.dart';
import '../core/services/local_storage_service.dart';
import 'user_view_model.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  final ProductRepository _productRepository;
  final ApiClient _apiClient;
  List<CartItem> _cartItems = [];
  List<Map<String, dynamic>> _offlineCartItems = [];
  List<CartItem> _offlineCartItemsWithDetails = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  LocalStorageService? _localStorage;
  bool _isCartLoading = false;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMoreData = true;
  int _totalCount = 0;
  int _totalPages = 0;

  CartViewModel(this._repository, this._productRepository, this._apiClient) {
    _initLocalStorage();
  }

  Future<void> _initLocalStorage() async {
    _localStorage = await LocalStorageService.getInstance();
    await _loadOfflineCart();
  }

  List<CartItem> get cartItems => _cartItems;
  List<Map<String, dynamic>> get offlineCartItems => _offlineCartItems;
  List<CartItem> get offlineCartItemsWithDetails => _offlineCartItemsWithDetails;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  ApiClient get apiClient => _apiClient;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;

  // Calculate total items in cart (online + offline)
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity) + 
                       _offlineCartItems.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));

  // Calculate total price of cart (online + offline)
  double get totalPrice {
    double onlineTotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    double offlineTotal = _offlineCartItemsWithDetails.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
    return onlineTotal + offlineTotal;
  }

  Future<void> _loadOfflineCart() async {
    if (_localStorage != null) {
      _offlineCartItems = await _localStorage!.getOfflineCart();
      notifyListeners();
    }
  }

  Future<void> loadOfflineCart() async {
    if (_isCartLoading) return;
    _isCartLoading = true;
    _cartItems.clear();
    _offlineCartItems.clear();
    _offlineCartItemsWithDetails.clear();
    await _loadOfflineCart();
    await _fetchOfflineCartProductDetails();
    _isCartLoading = false;
  }

  Future<void> _fetchOfflineCartProductDetails() async {
    _offlineCartItemsWithDetails.clear();
    if (_offlineCartItems.isEmpty) {
      notifyListeners();
      return;
    }
    try {
      List<Future<void>> futures = [];
      final addedIds = <String>{};
      for (final offlineItem in _offlineCartItems) {
        futures.add(() async {
          try {
            final productId = offlineItem['productId'] as String;
            if (addedIds.contains(productId)) return;
            final quantity = offlineItem['quantity'] as int;
            final product = await _productRepository.getById(productId);
            if (product != null) {
              final cartItem = CartItem(
                itemId: productId,
                name: product.name,
                price: product.price,
                totalPrice: product.price * quantity,
                quantity: quantity,
                imageUrl: product.media.isNotEmpty ? product.media.first.url : null,
              );
              _offlineCartItemsWithDetails.add(cartItem);
              addedIds.add(productId);
            }
          } catch (e) {
            print('Error fetching product details for cart item: $e');
          }
        }());
      }
      await Future.wait(futures);
      notifyListeners();
    } catch (e) {
      print('Error fetching offline cart product details: $e');
    }
  }

  // Load cart with pagination (first page)
  Future<String?> loadCart() async {
    return await _loadCartPage(1, reset: true);
  }

  // Load more cart items (next page)
  Future<String?> loadMoreCartItems() async {
    if (!_hasMoreData || _isLoadingMore) return null;
    return await _loadCartPage(_currentPage + 1, reset: false);
  }

  // Internal method to load a specific page
  Future<String?> _loadCartPage(int pageNumber, {required bool reset}) async {
    if (_isCartLoading) return null;
    _isCartLoading = true;
    
    try {
      if (reset) {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
    _cartItems.clear();
    _offlineCartItems.clear();
    _offlineCartItemsWithDetails.clear();
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();

      final response = await _repository.getCart(pageNumber: pageNumber, pageSize: _pageSize);
      final newCartItems = response.data ?? [];
      
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
        _cartItems = newCartItems;
      } else {
        _cartItems.addAll(newCartItems);
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
      _isCartLoading = false;
      notifyListeners();
    }
  }

  // Refresh cart (reset to first page)
  Future<String?> refreshCart() async {
    return await loadCart();
  }

  Future<String?> addToCart(String productId, int quantity, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cartItem = await _repository.addToCart(productId, quantity);
      _cartItems.add(cartItem);
      // No backend message available here
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateQuantity(String itemId, int quantity, BuildContext context) async {
    try {
      final response = await _repository.updateCartItem(itemId, quantity);
      
      // Update the specific item in the list without triggering loading state
      final index = _cartItems.indexWhere((item) => item.itemId == itemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: quantity,
          totalPrice: _cartItems[index].price * quantity,
        );
        notifyListeners();
      }
      
      return {
        'message': response.message,
        'success': response.success,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return {
        'message': errorMessage,
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> removeFromCart(String itemId, BuildContext context) async {
    try {
      final response = await _repository.removeFromCart(itemId);
      
      // Remove the specific item from the list without triggering loading state
      _cartItems.removeWhere((item) => item.itemId == itemId);
      notifyListeners();
      
      return {
        'message': response.message,
        'success': response.success,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return {
        'message': errorMessage,
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> removeOfflineCartItem(String productId, BuildContext context) async {
    try {
      await _localStorage?.removeOfflineCartItem(productId);
      await _loadOfflineCart(); // Reload offline cart
      
      return {
        'message': 'تم إزالة المنتج من السلة (محلياً)',
        'success': true,
        'offline': true,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'message': errorMessage,
        'success': false,
        'offline': true,
      };
    }
  }

  Future<Map<String, dynamic>> updateOfflineCartItemQuantity(String productId, int quantity, BuildContext context) async {
    try {
      if (quantity <= 0) {
        await _localStorage?.removeOfflineCartItem(productId);
      } else {
        await _localStorage?.updateOfflineCartItem(productId, quantity);
      }
      await _loadOfflineCart(); // Reload offline cart
      
      return {
        'message': quantity <= 0 
          ? 'تم إزالة المنتج من السلة (محلياً)'
          : 'تم تحديث الكمية (محلياً)',
        'success': true,
        'offline': true,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'message': errorMessage,
        'success': false,
        'offline': true,
      };
    }
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.itemId == productId);
  }

  int getItemQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.itemId == productId,
      orElse: () => CartItem(
        itemId: '',
        name: '',
        price: 0.0,
        totalPrice: 0.0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  Future<Map<String, dynamic>> addItemToCart(String itemId, int quantity, BuildContext context) async {
    try {
      // Check if user is logged in by checking if we have a token
      final hasToken = _apiClient.hasToken;
      
      if (!hasToken) {
        // Handle offline mode
        await _localStorage?.addOfflineCartItem(itemId, quantity);
        await _loadOfflineCart(); // Reload offline cart
        return {
          'message': 'تم إضافة المنتج إلى السلة (محلياً)',
          'success': true,
          'offline': true,
        };
      }

      // Online mode
      _isLoading = true;
      notifyListeners();

      final response = await _repository.addItemToCart(itemId, quantity);
      if (response.success) {
        // Optionally reload cart items here if needed
        await loadCart();
      }
      return {
        'message': response.message, 
        'success': response.success,
        'offline': false,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return {
        'message': errorMessage, 
        'success': false,
        'offline': false,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart after successful order
  void clearCart() {
    _cartItems.clear();
    _error = null;
    notifyListeners();
  }

  // Get cart count without loading full cart data
  int get cartItemsCount => _cartItems.length + _offlineCartItems.length;

  // Sync offline cart to backend when user logs in
  Future<void> syncOfflineCart() async {
    if (_localStorage == null || _offlineCartItems.isEmpty) return;
    
    try {
      final offlineCart = List<Map<String, dynamic>>.from(_offlineCartItems);
      
      for (final item in offlineCart) {
        try {
          final productId = item['productId'] as String;
          final quantity = item['quantity'] as int;
          
          final response = await _repository.addItemToCart(productId, quantity);
          if (response.success) {
            // Remove from offline list if successfully synced
            _offlineCartItems.removeWhere((offlineItem) => 
              offlineItem['productId'] == productId);
            await _localStorage!.removeOfflineCartItem(productId);
          }
        } catch (e) {
          print('Failed to sync cart item: $e');
          // Keep in offline list if sync fails
        }
      }
      
      // Clear offline cart from memory and storage after sync attempt
      _offlineCartItems.clear();
      _offlineCartItemsWithDetails.clear();
      await _localStorage?.clearOfflineCart();
      
      notifyListeners();
    } catch (e) {
      print('Error syncing offline cart: $e');
    }
  }

  // Clear offline cart (called on logout)
  Future<void> clearOfflineCart() async {
    _offlineCartItems.clear();
    _cartItems.clear();
    await _localStorage?.clearOfflineCart();
    notifyListeners();
  }

  // Clear all cart data (online and offline)
  Future<void> clearAllCartData() async {
    _cartItems.clear();
    _offlineCartItems.clear();
    _error = null;
    await _localStorage?.clearOfflineCart();
    notifyListeners();
  }

  // Clear data on logout (called by UserViewModel)
  void onLogout() {
    _cartItems.clear();
    _offlineCartItems.clear();
    _error = null;
    notifyListeners();
  }

  // Clear offline data after successful login/registration
  void clearOfflineDataAfterLogin() {
    _offlineCartItems.clear();
    _offlineCartItemsWithDetails.clear();
    notifyListeners();
  }
} 