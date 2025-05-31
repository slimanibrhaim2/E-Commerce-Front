import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/product.dart';

class FavoritesRepository extends api.ApiRepositoryBase<Product> implements BaseRepository<Product> {
  FavoritesRepository(super.apiClient);

  Future<List<Product>> getFavorites() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.favorites);
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  Future<Product> toggleFavorite(int productId) async {
    return handleApiCall(() async {
      final response = await apiClient.post(
        '${ApiEndpoints.toggleFavorite}$productId',
        {}, // Empty body as we're just toggling
      );
      if (response is Map<String, dynamic>) {
        return Product.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  @override
  Future<List<Product>> getAll() async {
    return getFavorites();
  }

  @override
  Future<Product?> getById(int id) {
    throw UnimplementedError('Not needed for favorites');
  }

  @override
  Future<Product> create(Product item) {
    throw UnimplementedError('Not needed for favorites');
  }

  @override
  Future<Product> update(Product item) {
    throw UnimplementedError('Not needed for favorites');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Not needed for favorites');
  }
} 