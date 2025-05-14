import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/base_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final BaseRepository<Product> _repository;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductsViewModel(this._repository);

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