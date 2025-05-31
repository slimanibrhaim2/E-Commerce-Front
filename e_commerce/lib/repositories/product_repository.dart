import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/product.dart';

class ProductRepository extends api.ApiRepositoryBase<Product> implements BaseRepository<Product> {
  ProductRepository(super.apiClient);

  Future<List<Product>> getProducts() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.products);
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  @override
  Future<Product?> getById(int id) async {
    return handleApiCall(() async {
      final response = await apiClient.get('${ApiEndpoints.productDetail}$id');
      if (response is Map<String, dynamic>) {
        return Product.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return handleListApiCall(() async {
      final response = await apiClient.get('${ApiEndpoints.categoryProducts}$category');
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  @override
  Future<List<Product>> getAll() async {
    return getProducts();
  }

  @override
  Future<Product> create(Product item) {
    throw UnimplementedError('Create not implemented yet');
  }

  @override
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

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Delete not implemented yet');
  }
} 