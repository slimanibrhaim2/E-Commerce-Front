import 'package:flutter/material.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/modern_snackbar.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  CartViewModel(this._repository);

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  double get total => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> addToCart(Product product) async {
    try {
      final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);
      
      if (existingItemIndex != -1) {
        // Increase quantity if item exists
        _items[existingItemIndex].quantity++;
      }
      else {
        // Add new item
        _items.add(CartItem(product: product));
      }
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج إلى السلة';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId, BuildContext context) async {
    try {
      final product = _items.firstWhere((item) => item.product.id == productId).product;
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
      
      ModernSnackbar.show(
        context: context,
        message: 'تمت إزالة ${product.name} من السلة',
        type: SnackBarType.info,
      );
    } catch (e) {
      _error = 'حدث خطأ أثناء إزالة المنتج من السلة';
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int quantity, BuildContext context) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.product.id == productId);
      if (itemIndex != -1) {
        final product = _items[itemIndex].product;
        if (quantity <= 0) {
          _items.removeAt(itemIndex);
          ModernSnackbar.show(
            context: context,
            message: 'تمت إزالة ${product.name} من السلة',
            type: SnackBarType.info,
          );
        } else {
          _items[itemIndex].quantity = quantity;
          ModernSnackbar.show(
            context: context,
            message: 'تم تحديث كمية ${product.name} إلى $quantity',
            type: SnackBarType.success,
          );
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث الكمية';
      notifyListeners();
    }
  }

  Future<void> clearCart(BuildContext context) async {
    try {
      _items.clear();
      notifyListeners();
      
      ModernSnackbar.show(
        context: context,
        message: 'تم تفريغ السلة بنجاح',
        type: SnackBarType.info,
      );
    } catch (e) {
      _error = 'حدث خطأ أثناء تفريغ السلة';
      notifyListeners();
    }
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: -1,
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
        category: 'Unknown',
        isFavorite: false,
      )),
    );
    return item.quantity;
  }
} 