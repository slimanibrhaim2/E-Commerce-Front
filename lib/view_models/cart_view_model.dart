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

  Future<String?> loadCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cartItems = await _repository.getCart();
      return null; // Success
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addToCart(String productId, int quantity, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cartItem = await _repository.addToCart(productId, quantity);
      _cartItems.add(cartItem);
      // No backend message available here
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateQuantity(int itemId, int quantity, BuildContext context) async {
    try {
      final updatedItem = await _repository.updateCartItem(itemId, quantity);
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
        notifyListeners();
      }
      // No backend message available here
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    }
  }

  Future<String?> removeFromCart(int itemId, BuildContext context) async {
    try {
      await _repository.removeFromCart(itemId);
      _cartItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      // No backend message for delete, return null
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return errorMessage;
    }
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getItemQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: -1,
        product: Product(
          id: null,
          name: '',
          description: '',
          price: 0,
          sku: '',
          stockQuantity: 0,
          isAvailable: false,
          categoryId: '',
          media: [],
          features: [],
        ),
        quantity: 0,
        totalPrice: 0,
      ),
    );
    return item.quantity;
  }

  Future<Map<String, dynamic>> addItemToCart(String itemId, int quantity, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _repository.addItemToCart(itemId, quantity);
      if (response.success) {
        // Optionally reload cart items here if needed
        await loadCart();
      }
      return {'message': response.message, 'success': response.success};
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _error = errorMessage;
      return {'message': errorMessage, 'success': false};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 