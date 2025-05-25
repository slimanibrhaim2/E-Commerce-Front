import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/modern_snackbar.dart';

class FavoritesViewModel extends ChangeNotifier {
  final ProductRepository _repository;
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

      // Get all products and filter favorites
      final allProducts = await _repository.getAll();
      _favorites = allProducts.where((product) => product.isFavorite).toList();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المفضلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId, BuildContext context) async {
    try {
      final productIndex = _favorites.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        // Optimistic update - update UI immediately
        final product = _favorites[productIndex];
        final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
        _favorites.removeAt(productIndex); // Remove from favorites list
        notifyListeners();

        // Make API call in background
        await _repository.update(updatedProduct);
        
        ModernSnackbar.show(
          context: context,
          message: 'تمت إزالة ${product.name} من المفضلة',
          type: SnackBarType.info,
        );
      }
    } catch (e) {
      // Revert changes if API call fails
      await loadFavorites(); // Reload favorites to ensure consistency
      _error = 'حدث خطأ أثناء تحديث حالة المفضلة';
      notifyListeners();
    }
  }

  Future<void> removeAllFavorites(BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update all favorite products to not favorite
      for (final product in _favorites) {
        final updatedProduct = product.copyWith(isFavorite: false);
        await _repository.update(updatedProduct);
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

  // Add this method to check if a product is in favorites
  bool isFavorite(int productId) {
    return _favorites.any((product) => product.id == productId);
  }
} 