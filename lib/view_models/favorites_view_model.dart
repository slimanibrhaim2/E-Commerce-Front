import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite.dart';
import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import '../core/api/api_response.dart';
import '../core/api/api_client.dart';
import 'user_view_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  final ApiClient _apiClient;
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoritesViewModel(this._repository, this._apiClient);

  List<Favorite> get favorites => _favorites;
  List<Product> get favoriteProducts => _favorites.map((f) => f.baseItem).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoritesCount => _favorites.length;
  ApiClient get apiClient => _apiClient;

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
        return {
          'message': 'يجب تسجيل الدخول لإدارة المفضلة',
          'success': false,
        };
      }

      // Check if item is already in favorites
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
    return _favorites.any((favorite) => favorite.itemId == itemId);
  }

  Favorite? getFavoriteByItemId(String itemId) {
    try {
      return _favorites.firstWhere((favorite) => favorite.itemId == itemId);
    } catch (e) {
      return null;
    }
  }
} 