import '../config/api_config.dart';

class ApiEndpoints {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Product endpoints
  static const String products = '/products';
  static const String productDetail = '/products/'; // Append product ID
  
  // Category endpoints
  static const String categories = '/products/categories';
  static const String categoryProducts = '/products/category/'; // Append category name

  // Favorites endpoints
  static const String favorites = '/favorites';
  static const String toggleFavorite = '/favorites/toggle/'; // Append product ID

  // Cart endpoints
  static const String cart = '/cart';
  static const String cartItem = '/cart/item/'; // Append item ID
  static const String updateCartItem = '/cart/update/'; // Append item ID
  static const String removeCartItem = '/cart/remove/'; // Append item ID
  static const String clearCart = '/cart/clear';

  // User endpoints
  static const String userProfile = '/user/profile';
} 