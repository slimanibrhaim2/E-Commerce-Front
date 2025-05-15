import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/base_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final BaseRepository<Product> _repository;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductsViewModel(this._repository);

  BaseRepository<Product> get repository => _repository;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _repository.getAll();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المنتجات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId) async {
    try {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        // Optimistic update - update UI immediately
        final product = _products[productIndex];
        final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
        _products[productIndex] = updatedProduct;
        notifyListeners();

        // Make API call in background
        await _repository.update(updatedProduct);
      }
    } catch (e) {
      // Revert changes if API call fails
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        _products[productIndex] = product.copyWith(isFavorite: !product.isFavorite);
        _error = 'حدث خطأ أثناء تحديث حالة المفضلة';
        notifyListeners();
      }
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.create(product);
      await loadProducts();
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.update(product);
      await loadProducts();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث المنتج';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.delete(id);
      await loadProducts();
    } catch (e) {
      _error = 'حدث خطأ أثناء حذف المنتج';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 