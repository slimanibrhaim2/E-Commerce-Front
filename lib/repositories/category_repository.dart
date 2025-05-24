import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/category.dart';

class CategoryRepository extends api.ApiRepositoryBase<Category> implements BaseRepository<Category> {
  CategoryRepository(ApiClient apiClient) : super(apiClient);

  Future<List<Category>> getCategories() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.categories);
      if (response is List) {
        return response.asMap().entries.map((entry) => Category(
          id: entry.key + 1,
          name: entry.value.toString(),
          image: '',
        )).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  @override
  Future<List<Category>> getAll() async {
    return getCategories();
  }

  @override
  Future<Category?> getById(int id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.categories);
      if (response is List && id > 0 && id <= response.length) {
        return Category(
          id: id,
          name: response[id - 1].toString(),
          image: '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  // These methods are required by the interface but we're not implementing them yet
  @override
  Future<Category> create(Category item) {
    throw UnimplementedError('Create not implemented yet');
  }

  @override
  Future<Category> update(Category item) {
    throw UnimplementedError('Update not implemented yet');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Delete not implemented yet');
  }
} 