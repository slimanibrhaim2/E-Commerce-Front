import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../core/api/api_response.dart';
import '../repositories/base_repository.dart';
import '../models/favorite.dart';

class FavoritesRepository extends api.ApiRepositoryBase<Favorite> implements BaseRepository<Favorite> {
  FavoritesRepository(super.apiClient);

  Future<ApiResponse<List<Favorite>>> getFavorites({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.favorites}$queryParams';
      final response = await apiClient.get(endpoint);
      
      List<Favorite> favorites = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          favorites = innerData.map((json) => Favorite.fromJson(json)).toList();
        }
      }

      // Extract pagination metadata from backend response
      Map<String, dynamic>? paginationMetadata;
      if (outerData is Map) {
        paginationMetadata = {
          'pageNumber': outerData['pageNumber'],
          'pageSize': outerData['pageSize'],
          'totalPages': outerData['totalPages'],
          'totalCount': outerData['totalCount'],
          'hasPreviousPage': outerData['hasPreviousPage'],
          'hasNextPage': outerData['hasNextPage'],
        };
      }
      
      return ApiResponse<List<Favorite>>(
        data: favorites,
        message: response['message'] as String?,
        success: response['success'] ?? false,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<ApiResponse<String>> addToFavorites(String itemId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.addToFavorites,
        {
          'itemId': itemId,
        },
      );
      
      return ApiResponse<String>(
        data: response['data'] as String?,
        message: response['message'] as String?,
        success: response['success'] ?? false,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<ApiResponse<String>> removeFromFavorites(String itemId) async {
    try {
      final endpoint = '${ApiEndpoints.favorites}/$itemId';
      
      final response = await apiClient.delete(endpoint);
      
      // Handle different response structures
      String? message;
      bool success = false;
      int? resultStatus;
      String? data;
      
      if (response is Map<String, dynamic>) {
        message = response['message'] as String?;
        success = response['success'] as bool? ?? false;
        resultStatus = response['resultStatus'] as int?;
        
        // Handle different data types that might be returned
        final responseData = response['data'];
        if (responseData != null) {
          if (responseData is String) {
            data = responseData;
          } else if (responseData is bool) {
            data = responseData.toString();
          } else {
            data = responseData.toString();
          }
        }
      } else {
        // If response is not a map, try to convert it
        message = response.toString();
        success = false;
      }
      
      return ApiResponse<String>(
        data: data,
        message: message,
        success: success,
        resultStatus: resultStatus,
      );
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  @override
  Future<List<Favorite>> getAll() async {
    final response = await getFavorites();
    return response.data ?? [];
  }

  @override
  Future<Favorite?> getById(int id) {
    throw UnimplementedError('Not needed for favorites');
  }

  @override
  Future<Favorite> create(Favorite item) {
    throw UnimplementedError('Use addToFavorites instead');
  }

  @override
  Future<Favorite> update(Favorite item) {
    throw UnimplementedError('Not needed for favorites');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Use removeFromFavorites instead');
  }
} 