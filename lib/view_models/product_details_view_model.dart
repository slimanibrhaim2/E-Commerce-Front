import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/base_repository.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  final BaseRepository<Product> _repository;
  Product? _product;
  bool _isLoading = false;
  String? _error;
  bool _isInCart = false;

  ProductDetailsViewModel(this._repository);

  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInCart => _isInCart;

  Future<void> loadProduct(int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _product = await _repository.getById(productId);
      
      if (_product == null) {
        _error = 'المنتج غير موجود';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل تفاصيل المنتج';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite() async {
    if (_product == null) return;

    // Optimistic update - update UI immediately
    final updatedProduct = _product!.copyWith(isFavorite: !_product!.isFavorite);
    _product = updatedProduct;
    notifyListeners();

    try {
      // Make API call in background
      await _repository.update(updatedProduct);
    } catch (e) {
      // Revert changes if API call fails
      _product = _product!.copyWith(isFavorite: !_product!.isFavorite);
      _error = 'حدث خطأ أثناء تحديث حالة المفضلة';
      notifyListeners();
    }
  }

  Future<void> addToCart() async {
    if (_product == null) return;

    try {
      _isInCart = true;
      notifyListeners();
      
      // TODO: Implement actual cart functionality
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Show success message
      _error = 'تمت إضافة المنتج إلى السلة';
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج إلى السلة';
    } finally {
      _isInCart = false;
      notifyListeners();
    }
  }
} 