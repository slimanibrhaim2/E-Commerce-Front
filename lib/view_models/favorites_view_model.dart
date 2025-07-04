import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite.dart';
import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/product_repository.dart';
import '../core/api/api_response.dart';
import '../core/api/api_client.dart';
import '../core/services/local_storage_service.dart';
import 'user_view_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  final ProductRepository _productRepository;
  final ApiClient _apiClient;
  List<Favorite> _favorites = [];
  List<String> _offlineFavorites = [];
  bool _isLoading = false;
  String? _error;
  LocalStorageService? _localStorage;

  FavoritesViewModel(this._repository, this._productRepository, this._apiClient) {
    _initLocalStorage();
  }

  Future<void> _initLocalStorage() async {
    _localStorage = await LocalStorageService.getInstance();
    await _loadOfflineFavorites();
  }

  List<Favorite> get favorites => _favorites;
  List<Product> get favoriteProducts => _favorites.map((f) => f.baseItem).toList();
  List<String> get offlineFavorites => _offlineFavorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoritesCount => _favorites.length + _offlineFavorites.length;
  ApiClient get apiClient => _apiClient;

  Future<void> _loadOfflineFavorites() async {
    if (_localStorage != null) {
      _offlineFavorites = await _localStorage!.getOfflineFavorites();
      notifyListeners();
    }
  }

  Future<void> loadOfflineFavorites() async {
    await _loadOfflineFavorites();
    // Fetch product details for offline favorites
    await _fetchOfflineFavoriteProducts();
  }

  Future<void> _fetchOfflineFavoriteProducts() async {
    if (_offlineFavorites.isEmpty) return;
    
    try {
      for (final productId in _offlineFavorites) {
        try {
          final product = await _productRepository.getById(productId);
          if (product != null) {
            // Create a Favorite object from the product
            final favorite = Favorite(
              id: productId,
              userId: '',
              baseItemId: productId,
              itemId: productId,
              quantity: product.stockQuantity ?? 0,
              baseItem: product,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            // Add to favorites list if not already present
            if (!_favorites.any((f) => f.itemId == productId)) {
              _favorites.add(favorite);
            }
          }
        } catch (e) {
          print('Error fetching product $productId: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching offline favorite products: $e');
    }
  }

  Future<String?> loadFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Clear favorites first
      _favorites = [];
      
      final response = await _repository.getFavorites();
      _favorites = response.data ?? [];
      
      // Return backend message if available
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      // Clear favorites on error
      _favorites = [];
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(String itemId, BuildContext context) async {
    try {
      // Check if user is logged in
      final userViewModel = context.read<UserViewModel>();
      if (!userViewModel.isLoggedIn) {
        // Handle offline mode
        final isCurrentlyFavorite = isFavorite(itemId);
        
        if (isCurrentlyFavorite) {
          // Remove from offline favorites
          await _localStorage?.removeOfflineFavorite(itemId);
          _offlineFavorites.remove(itemId);
          notifyListeners();
          return {
            'message': 'تم إزالة المنتج من المفضلة (محلياً)',
            'success': true,
            'offline': true,
          };
        } else {
          // Add to offline favorites
          await _localStorage?.addOfflineFavorite(itemId);
          _offlineFavorites.add(itemId);
          notifyListeners();
        return {
            'message': 'تم إضافة المنتج إلى المفضلة (محلياً)',
            'success': true,
            'offline': true,
        };
        }
      }

      // Online mode - user is logged in
      final isCurrentlyFavorite = isFavorite(itemId);
      
      ApiResponse<String> response;
      if (isCurrentlyFavorite) {
        // Remove from favorites
        response = await _repository.removeFromFavorites(itemId);
        
        // Remove from local list without triggering loading state
        if (response.success) {
          _favorites.removeWhere((favorite) => favorite.itemId == itemId);
          notifyListeners();
        }
      } else {
        // Add to favorites
        response = await _repository.addToFavorites(itemId);
        
        // Note: For add operation, we need to reload favorites to get the new item details
        // But we can do it without showing loading state
        if (response.success) {
          // Reload favorites in background without setting loading state
          _reloadFavoritesSilently();
        }
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
    }
  }

  // Private method to reload favorites without showing loading state
  Future<void> _reloadFavoritesSilently() async {
    try {
      final response = await _repository.getFavorites();
      _favorites = response.data ?? [];
      notifyListeners();
    } catch (e) {
      // Silently handle errors for background reload
      print('Silent favorites reload error: $e');
    }
  }

  Future<Map<String, dynamic>> addToFavorites(String itemId, BuildContext context) async {
    try {
      // Check if user is logged in
      final userViewModel = context.read<UserViewModel>();
      if (!userViewModel.isLoggedIn) {
        return {
          'message': 'يجب تسجيل الدخول لإضافة منتجات إلى المفضلة',
          'success': false,
        };
      }

      final response = await _repository.addToFavorites(itemId);
      
      if (response.success) {
        // Reload favorites in background without showing loading state
        _reloadFavoritesSilently();
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

  Future<Map<String, dynamic>> removeFromFavorites(String itemId, BuildContext context) async {
    try {
      // Check if user is logged in
      final userViewModel = context.read<UserViewModel>();
      if (!userViewModel.isLoggedIn) {
        return {
          'message': 'يجب تسجيل الدخول لإزالة منتجات من المفضلة',
          'success': false, 
        };
      }

      final response = await _repository.removeFromFavorites(itemId);
      
      // Remove from local list without triggering loading state
      if (response.success) {
        _favorites.removeWhere((favorite) => favorite.itemId == itemId);
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

  bool isFavorite(String itemId) {
    return _favorites.any((favorite) => favorite.itemId == itemId) || 
           _offlineFavorites.contains(itemId);
  }

  Favorite? getFavoriteByItemId(String itemId) {
    try {
      return _favorites.firstWhere((favorite) => favorite.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  // Sync offline favorites to backend when user logs in
  Future<void> syncOfflineFavorites() async {
    if (_localStorage == null || _offlineFavorites.isEmpty) return;
    
    try {
      final offlineFavorites = List<String>.from(_offlineFavorites);
      
      for (final productId in offlineFavorites) {
        try {
          final response = await _repository.addToFavorites(productId);
          if (response.success) {
            // Remove from offline list if successfully synced
            _offlineFavorites.remove(productId);
            await _localStorage!.removeOfflineFavorite(productId);
          }
        } catch (e) {
          print('Failed to sync favorite $productId: $e');
          // Keep in offline list if sync fails
        }
      }
      
      // Clear offline favorites from memory and storage after sync attempt
      _offlineFavorites.clear();
      await _localStorage?.clearOfflineFavorites();
      
      notifyListeners();
    } catch (e) {
      print('Error syncing offline favorites: $e');
    }
  }

  // Clear offline favorites (called on logout)
  Future<void> clearOfflineFavorites() async {
    _offlineFavorites.clear();
    _favorites.clear();
    await _localStorage?.clearOfflineFavorites();
    notifyListeners();
  }

  // Clear all favorites data (online and offline)
  Future<void> clearAllFavoritesData() async {
    _favorites.clear();
    _offlineFavorites.clear();
    _error = null;
    await _localStorage?.clearOfflineFavorites();
    notifyListeners();
  }

  // Clear data on logout (called by UserViewModel)
  void onLogout() {
    _favorites.clear();
    _offlineFavorites.clear();
    _error = null;
    notifyListeners();
  }

  // Clear offline data after successful login/registration
  void clearOfflineDataAfterLogin() {
    _offlineFavorites.clear();
    notifyListeners();
  }
} 