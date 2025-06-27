import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/modern_snackbar.dart';

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

  Future<String?> loadFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.getFavorites();
      _favorites = response.data ?? [];
      
      // Return backend message if available
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addToFavorites(String itemId, BuildContext context) async {
    try {
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

  Future<Map<String, dynamic>> removeAllFavorites(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Remove each favorite item
      for (final favorite in _favorites) {
        await _repository.removeFromFavorites(favorite.baseItemId);
      }

      _favorites.clear();
      
      return {
        'message': 'تمت إزالة جميع المنتجات من المفضلة بنجاح',
        'success': true,
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