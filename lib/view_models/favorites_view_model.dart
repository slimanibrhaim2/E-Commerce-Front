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

  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get favorites directly from the API
      _favorites = await _repository.getFavorites();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المفضلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId, BuildContext context) async {
    try {
      // Make API call to toggle favorite
      final updatedProduct = await _repository.toggleFavorite(productId);
      
      // Update local state based on API response
      if (updatedProduct.isFavorite) {
        _favorites.add(updatedProduct);
        ModernSnackbar.show(
          context: context,
          message: 'تمت إضافة ${updatedProduct.name} إلى المفضلة',
          type: SnackBarType.success,
        );
      } else {
        _favorites.removeWhere((p) => p.id == productId);
        ModernSnackbar.show(
          context: context,
          message: 'تمت إزالة ${updatedProduct.name} من المفضلة',
          type: SnackBarType.info,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث حالة المفضلة';
      notifyListeners();
      
      ModernSnackbar.show(
        context: context,
        message: _error!,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> removeAllFavorites(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Clear favorites in the API
      for (final product in _favorites) {
        await _repository.toggleFavorite(product.id);
      }

      _favorites.clear();
      
      ModernSnackbar.show(
        context: context,
        message: 'تمت إزالة جميع المنتجات من المفضلة',
        type: SnackBarType.info,
      );
    } catch (e) {
      _error = 'حدث خطأ أثناء إزالة جميع المفضلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int productId) {
    return _favorites.any((product) => product.id == productId);
  }
} 