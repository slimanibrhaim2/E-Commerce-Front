import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../widgets/modern_snackbar.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  CartViewModel(this._repository);

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculate total items in cart
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Calculate total price of cart
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cartItems = await _repository.getCart();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل السلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, int quantity, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cartItem = await _repository.addToCart(productId, quantity);
      _cartItems.add(cartItem);
      
      ModernSnackbar.show(
        context: context,
        message: 'تمت إضافة المنتج إلى السلة',
        type: SnackBarType.success,
      );
    } catch (e) {
      ModernSnackbar.show(
        context: context,
        message: 'حدث خطأ أثناء إضافة المنتج إلى السلة',
        type: SnackBarType.error,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int itemId, int quantity, BuildContext context) async {
    try {
      final updatedItem = await _repository.updateCartItem(itemId, quantity);
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث الكمية';
      notifyListeners();
      
      ModernSnackbar.show(
        context: context,
        message: _error!,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> removeFromCart(int itemId, BuildContext context) async {
    try {
      await _repository.removeFromCart(itemId);
      _cartItems.removeWhere((item) => item.id == itemId);
      
      ModernSnackbar.show(
        context: context,
        message: 'تمت إزالة المنتج من السلة',
        type: SnackBarType.info,
      );
      
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء إزالة المنتج من السلة';
      notifyListeners();
      
      ModernSnackbar.show(
        context: context,
        message: _error!,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> clearCart(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.clearCart();
      _cartItems.clear();
      
      ModernSnackbar.show(
        context: context,
        message: 'تم تفريغ السلة',
        type: SnackBarType.info,
      );
    } catch (e) {
      _error = 'حدث خطأ أثناء تفريغ السلة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: -1,
        product: Product(
          id: -1,
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
          isFavorite: false,
        ),
        quantity: 0,
        totalPrice: 0,
      ),
    );
    return item.quantity;
  }
} 