import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/base_repository.dart';

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
  final BaseRepository<Product> _repository;
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
      } else {
        // Add new item
        _items.add(CartItem(product: product));
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء إضافة المنتج إلى السلة';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ أثناء إزالة المنتج من السلة';
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.product.id == productId);
      if (itemIndex != -1) {
        if (quantity <= 0) {
          _items.removeAt(itemIndex);
        } else {
          _items[itemIndex].quantity = quantity;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث الكمية';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      _items.clear();
      notifyListeners();
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
        isFavorite: false,
      )),
    );
    return item.quantity;
  }
} 