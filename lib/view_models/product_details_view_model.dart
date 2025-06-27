import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/favorites_view_model.dart';
import '../widgets/modern_snackbar.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  Product? _product;
  bool _isLoading = false;
  bool _isInCart = false;
  String? _error;

  ProductDetailsViewModel(this._repository);

  Product? get product => _product;
  bool get isLoading => _isLoading;
  bool get isInCart => _isInCart;
  String? get error => _error;

  Future<void> loadProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _product = await _repository.getById(productId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {
    if (_product == null) return;

    try {
      final favoritesViewModel = context.read<FavoritesViewModel>();
      
      final result = await favoritesViewModel.toggleFavorite(_product!.id!, context);
      
      final message = result['message'] as String?;
      final success = result['success'] as bool? ?? false;
      
      if (message != null && context.mounted) {
        ModernSnackbar.show(
          context: context,
          message: message,
          type: success ? SnackBarType.success : SnackBarType.error,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ModernSnackbar.show(
          context: context,
          message: 'حدث خطأ أثناء تحديث حالة المفضلة',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> addToCart(BuildContext context) async {
    if (_product == null) return;

    try {
      _isInCart = true;
      notifyListeners();

      // Get CartViewModel and add product to cart
      final cartViewModel = context.read<CartViewModel>();
      await cartViewModel.addToCart(_product!.id!, 1, context);
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج إلى السلة';
      notifyListeners();
    } finally {
      _isInCart = false;
      notifyListeners();
    }
  }
} 