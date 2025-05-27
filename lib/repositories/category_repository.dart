import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/category.dart';

class CategoryRepository extends api.ApiRepositoryBase<Category> implements BaseRepository<Category> {
  CategoryRepository(super.apiClient);

  Future<List<Category>> getCategories() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.categories);
      if (response is List) {
        return response.asMap().entries.map((entry) => Category.fromJson({
          'id': entry.key + 1,
          'name': entry.value.toString(),
          'image':'', // this api doesn't give a image for the category so we use this latar we will replace this fucntion by
                      // return response.map((json) => Category.fromJson(json)).toList();
        })).toList();
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
        return Category.fromJson({
          'id': id,
          'name': response[id - 1].toString(),
          'image': '',
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  @override
  Future<Category> create(Category item) async {
    final jsonData = item.toJson();
    final response = await apiClient.post(ApiEndpoints.categories, jsonData);
    return Category.fromJson(response);
  }

  @override
  Future<Category> update(Category item) async {
    final jsonData = item.toJson();
    final response = await apiClient.post('${ApiEndpoints.categories}/${item.id}', jsonData);
    return Category.fromJson(response);
  }

  @override
  Future<bool> delete(int id) async {
    try {
      await apiClient.post('${ApiEndpoints.categories}/$id', {'_method': 'DELETE'});
      return true;
    } catch (e) {
      return false;
    }
  }
} 