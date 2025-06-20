import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../core/api/api_response.dart';
import '../repositories/base_repository.dart';
import '../models/category.dart';

class CategoryRepository extends api.ApiRepositoryBase<Category> implements BaseRepository<Category> {
  CategoryRepository(super.apiClient);

  /// Fetch all categories (from real API)
  Future<ApiResponse<List<Category>>> getCategories() async {
    final response = await apiClient.get(ApiEndpoints.categories);
    print('Categories response: $response');

    List<Category> categories = [];
    final outerData = response['data'];
    if (outerData is Map && outerData.containsKey('data')) {
      final innerData = outerData['data'];
      if (innerData is List) {
        categories = innerData.map((json) => Category.fromJson(json)).toList();
      }
    }

    return ApiResponse(
      data: categories,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  /// Required by BaseRepository — used internally
  @override
  Future<List<Category>> getAll() async {
    final response = await getCategories();
    return response.data ?? [];
  }

  /// Not supported
  @override
  Future<Category?> getById(int id) async {
    throw UnimplementedError('getById is not supported for categories');
  }

  /// Not supported (Read-only)
  @override
  Future<Category> create(Category item) {
    throw UnimplementedError('Create category is not supported');
  }

  /// Not supported (Read-only)
  @override
  Future<Category> update(Category item) {
    throw UnimplementedError('Update category is not supported');
  }

  /// Not supported (Read-only)
  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Delete category is not supported');
  }
}
