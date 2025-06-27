import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../models/product.dart';
import '../core/api/api_response.dart';

class ProductRepository extends api.ApiRepositoryBase<Product> {
  ProductRepository(super.apiClient);

  Future<bool> handleBooleanApiCall(Future<bool> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.products);
      if (response is Map<String, dynamic> &&
          response.containsKey('data') &&
          response['data'] is Map<String, dynamic> &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        final List<dynamic> productListJson = response['data']['data'];
        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format for getProducts');
    });
  }

  @override
  Future<Product?> getById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.productDetail}$id');
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          if (response['data'] is Map<String, dynamic>) {
            return Product.fromJson(response['data']);
          } else {
            return null; // Product not found, data is null
          }
        }
        // Unwrapped response support
        return Product.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return handleListApiCall(() async {
      final endpoint = '${ApiEndpoints.categoryProducts}$categoryId';
      final response = await apiClient.get(endpoint);
      if (response is Map<String, dynamic> &&
          response.containsKey('data') &&
          response['data'] is Map<String, dynamic> &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        final List<dynamic> productListJson = response['data']['data'];
        return productListJson.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format for getProductsByCategory');
    });
  }

  Future<List<Product>> getAll() async {
    return getProducts();
  }

  Future<ApiResponse<Product>> create(Product item) async {
    final response = await apiClient.post(
      ApiEndpoints.aggregateProduct,
      item.toJson(),
    );

    final newProduct = item.copyWith(id: response['data']);
    
    return ApiResponse(
      data: newProduct,
      success: response['success'],
      message: response['message'],
    );
  }

  Future<Product> update(Product item) async {
    return handleApiCall(() async {
      final response = await apiClient.post(
        '${ApiEndpoints.productDetail}${item.id}',
        item.toJson(),
      );
      if (response is Map<String, dynamic>) {
        return Product.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  Future<bool> delete(int id) async {
    try {
      await apiClient.delete('${ApiEndpoints.productDetail}$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }
} 