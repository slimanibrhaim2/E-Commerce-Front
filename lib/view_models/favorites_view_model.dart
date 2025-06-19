import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import '../widgets/modern_snackbar.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;
  List<Product> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoritesViewModel(this._repository);

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> loadFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get favorites directly from the API
      _favorites = await _repository.getFavorites();
      return null; // Success
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> toggleFavorite(int productId, BuildContext context) async {
    try {
      // Make API call to toggle favorite
      final updatedProduct = await _repository.toggleFavorite(productId);
      
      // Update local state based on API response
      if (updatedProduct.isFavorite) {
        _favorites.add(updatedProduct);
        notifyListeners();
        return 'تمت إضافة ${updatedProduct.name} إلى المفضلة بنجاح';
      } else {
        _favorites.removeWhere((p) => p.id == productId);
        notifyListeners();
        return 'تمت إزالة ${updatedProduct.name} من المفضلة بنجاح';
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      notifyListeners();
      return errorMessage;
    }
  }

  Future<String?> removeAllFavorites(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Clear favorites in the API
      for (final product in _favorites) {
        await _repository.toggleFavorite(product.id);
      }

      _favorites.clear();
      
      return 'تمت إزالة جميع المنتجات من المفضلة بنجاح';
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int productId) {
    return _favorites.any((product) => product.id == productId);
  }
} 