import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _favoritesKey = 'offline_favorites';
  static const String _cartKey = 'offline_cart';
  
  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;
  
  LocalStorageService._();
  
  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  // Favorites methods
  Future<List<String>> getOfflineFavorites() async {
    final favoritesJson = _prefs?.getString(_favoritesKey);
    if (favoritesJson != null) {
      try {
        final List<dynamic> favorites = json.decode(favoritesJson);
        return favorites.cast<String>();
      } catch (e) {
        // Error parsing offline favorites
        return [];
      }
    }
    return [];
  }
  
  Future<void> addOfflineFavorite(String productId) async {
    final favorites = await getOfflineFavorites();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await _prefs?.setString(_favoritesKey, json.encode(favorites));
    }
  }
  
  Future<void> removeOfflineFavorite(String productId) async {
    final favorites = await getOfflineFavorites();
    favorites.remove(productId);
    await _prefs?.setString(_favoritesKey, json.encode(favorites));
  }
  
  Future<bool> isOfflineFavorite(String productId) async {
    final favorites = await getOfflineFavorites();
    return favorites.contains(productId);
  }
  
  Future<void> clearOfflineFavorites() async {
    await _prefs?.remove(_favoritesKey);
  }
  
  // Cart methods
  Future<List<Map<String, dynamic>>> getOfflineCart() async {
    final cartJson = _prefs?.getString(_cartKey);
    if (cartJson != null) {
      try {
        final List<dynamic> cart = json.decode(cartJson);
        return cart.cast<Map<String, dynamic>>();
      } catch (e) {
        // Error parsing offline cart
        return [];
      }
    }
    return [];
  }
  
  Future<void> addOfflineCartItem(String productId, int quantity) async {
    final cart = await getOfflineCart();
    final existingIndex = cart.indexWhere((item) => item['productId'] == productId);
    
    if (existingIndex != -1) {
      // Update existing item quantity
      cart[existingIndex]['quantity'] = (cart[existingIndex]['quantity'] ?? 0) + quantity;
    } else {
      // Add new item
      cart.add({
        'productId': productId,
        'quantity': quantity,
        'addedAt': DateTime.now().toIso8601String(),
      });
    }
    
    await _prefs?.setString(_cartKey, json.encode(cart));
  }
  
  Future<void> updateOfflineCartItem(String productId, int quantity) async {
    final cart = await getOfflineCart();
    final existingIndex = cart.indexWhere((item) => item['productId'] == productId);
    
    if (existingIndex != -1) {
      if (quantity <= 0) {
        cart.removeAt(existingIndex);
      } else {
        cart[existingIndex]['quantity'] = quantity;
      }
      await _prefs?.setString(_cartKey, json.encode(cart));
    }
  }
  
  Future<void> removeOfflineCartItem(String productId) async {
    final cart = await getOfflineCart();
    cart.removeWhere((item) => item['productId'] == productId);
    await _prefs?.setString(_cartKey, json.encode(cart));
  }
  
  Future<void> clearOfflineCart() async {
    await _prefs?.remove(_cartKey);
  }
  
  Future<int> getOfflineCartItemQuantity(String productId) async {
    final cart = await getOfflineCart();
    final item = cart.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }
  
  Future<int> getOfflineCartItemsCount() async {
    final cart = await getOfflineCart();
    return cart.length;
  }

  // Clear all offline data (called on logout)
  Future<void> clearAllOfflineData() async {
    await _prefs?.remove(_favoritesKey);
    await _prefs?.remove(_cartKey);
  }
} 