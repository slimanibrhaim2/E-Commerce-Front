import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/modern_snackbar.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCategory;

  ProductsViewModel(this._repository);

  ProductRepository get repository => _repository;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategory => _currentCategory;

  Future<void> loadProducts({String? category}) async {
    try {
      _isLoading = true;
      _error = null;
      _currentCategory = category;
      notifyListeners();

      if (category != null) {
        _products = await _repository.getProductsByCategory(category);
      } else {
      _products = await _repository.getAll();
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل المنتجات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId, BuildContext context) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
      
      // Optimistic update
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }

      await _repository.update(updatedProduct);
      
      ModernSnackbar.show(
        context: context,
        message: updatedProduct.isFavorite 
          ? 'تمت إضافة ${updatedProduct.name} إلى المفضلة'
          : 'تمت إزالة ${updatedProduct.name} من المفضلة',
        type: updatedProduct.isFavorite ? SnackBarType.success : SnackBarType.info,
      );
    } catch (e) {
      // Revert optimistic update
      final product = _products.firstWhere((p) => p.id == productId);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = product.copyWith(isFavorite: !product.isFavorite);
        notifyListeners();
      }
      
      ModernSnackbar.show(
        context: context,
        message: 'حدث خطأ أثناء تحديث المفضلة',
        type: SnackBarType.error,
      );
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