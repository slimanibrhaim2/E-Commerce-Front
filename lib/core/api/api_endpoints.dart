import '../config/api_config.dart';

class ApiEndpoints {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Product endpoints
  static const String products = '/products';
  static const String productDetail = '/products/'; // Append product ID
  
  // Category endpoints
  static const String categories = '/products/categories';
  static const String categoryProducts = '/products/category/'; // Append category name
} 