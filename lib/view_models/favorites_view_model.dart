import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorite.dart';
import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/modern_snackbar.dart';
import '../core/api/api_response.dart';
import 'user_view_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoritesViewModel(this._repository);

  List<Favorite> get favorites => _favorites;
  List<Product> get favoriteProducts => _favorites.map((f) => f.baseItem).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoritesCount => _favorites.length;

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
      } else {
        // Add to favorites
        response = await _repository.addToFavorites(itemId);
      }
      
      // Only reload favorites if the API call was successful
      if (response.success) {
        _isLoading = true;
        notifyListeners();
        await loadFavorites();
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

      _isLoading = true;
      notifyListeners();

      final response = await _repository.addToFavorites(itemId);
      
      if (response.success) {
        // Reload favorites to get updated list
        await loadFavorites();
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
    } finally {
      _isLoading = false;
      notifyListeners();
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

      _isLoading = true;
      notifyListeners();

      final response = await _repository.removeFromFavorites(itemId);
      
      if (response.success) {
        // Reload favorites to get updated list
        await loadFavorites();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String itemId) {
    return _favorites.any((favorite) => favorite.baseItemId == itemId);
  }

  Favorite? getFavoriteByItemId(String itemId) {
    try {
      return _favorites.firstWhere((favorite) => favorite.baseItemId == itemId);
    } catch (e) {
      return null;
    }
  }
} 