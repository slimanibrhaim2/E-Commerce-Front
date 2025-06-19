import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

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

  Future<String?> loadProducts({String? category}) async {
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
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(isFavorite: !product.isFavorite);
      
      // Optimistic update
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }

      await _repository.update(updatedProduct);
      
      return updatedProduct.isFavorite 
        ? 'تمت إضافة ${updatedProduct.name} إلى المفضلة بنجاح'
        : 'تمت إزالة ${updatedProduct.name} من المفضلة بنجاح';
    } catch (e) {
      // Revert optimistic update
      final product = _products.firstWhere((p) => p.id == productId);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = product.copyWith(isFavorite: !product.isFavorite);
        notifyListeners();
      }
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    }
  }

  Future<String?> addProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.create(product);
      await loadProducts();
      return 'تم إضافة المنتج بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.update(product);
      await loadProducts();
      return 'تم تحديث المنتج بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteProduct(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.delete(id);
      await loadProducts();
      return 'تم حذف المنتج بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 