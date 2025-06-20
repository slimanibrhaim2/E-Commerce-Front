import '../config/api_config.dart';

class ApiEndpoints {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Product endpoints
  static const String products = '/products';
  static const String productDetail = '/products/'; // Append product ID
  
  // Category endpoints
  static const String categories = '/api/Category';
  static const String categoryProducts = '/api/products/category/'; // Append category ID

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
  static const String userProfile = '/api/users/me';
  // static const String users = '/api/users';
  // static const String userDetail = '/api/users/'; // Append user ID
  // static const String userSearch = '/api/users/search';

  // Address endpoints
  static const String addresses = '/api/addresses';
  static const String addressDetail = '/api/addresses/'; // Append address ID

  // Aggregate product endpoint
  static const String aggregateProduct = '/products/aggregate';

  // New endpoints for register and verify-otp
  static const String register = '/api/Auth/register';
  static const String verifyOtp = '/api/Auth/verify-otp';

  // Login endpoint
  static const String login = '/api/Auth/login';
} 