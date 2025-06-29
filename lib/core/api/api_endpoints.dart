import '../config/api_config.dart';

class ApiEndpoints {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Product endpoints
  static const String products = '/api/products';
  static const String productDetail = '/api/products/'; // Append product ID
  
  // Category endpoints
  static const String categories = '/api/Category';
  static const String categoryProducts = '/api/products/category/'; // Append category ID
  static const String categoryImage = '/api/Category/image/'; // Append imagePath

  // Media endpoints
  static const String mediaFile = '/api/Media/file/'; // Append filePath
  static const String userFile = '/api/files/'; // Append filePath

  // Favorites endpoints
  static const String favorites = '/api/Favorite';
  static const String addToFavorites = '/api/Favorite';

  // Cart endpoints
  static const String myCart = '/api/Cart/my-cart';
  static const String myCartItems = '/api/Cart/my-cart-items';
  static const String addCartItem = '/api/Cart/add-item';
  static const String updateCartItem = '/api/Cart/update-item';
  static const String removeCartItem = '/api/Cart/remove-item/'; // Append itemId

  // User endpoints
  static const String userProfile = '/api/users/me';
  // static const String users = '/api/users';
  // static const String userDetail = '/api/users/'; // Append user ID
  // static const String userSearch = '/api/users/search';

  // Address endpoints
  static const String addresses = '/api/addresses';
  static const String addressDetail = '/api/addresses/'; // Append address ID

  // Aggregate product endpoint
  static const String aggregateProduct = '/api/products/aggregate';


  // New endpoints for register and verify-otp
  static const String register = '/api/Auth/register';
  static const String verifyOtp = '/api/Auth/verify-otp';

  // Login endpoint
  static const String login = '/api/Auth/login';
} 