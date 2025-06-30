import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../core/api/api_response.dart';
import '../repositories/base_repository.dart';
import '../models/favorite.dart';

class FavoritesRepository extends api.ApiRepositoryBase<Favorite> implements BaseRepository<Favorite> {
  FavoritesRepository(super.apiClient);

  Future<ApiResponse<List<Favorite>>> getFavorites() async {
    try {
      final response = await apiClient.get(ApiEndpoints.favorites);
      
      List<Favorite> favorites = [];
      
      // Handle wrapped response structure
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final favoritesData = data['data'];
            if (favoritesData is List) {
              favorites = favoritesData.map((json) => Favorite.fromJson(json)).toList();
      }
          }
        }
        
        return ApiResponse<List<Favorite>>(
          data: favorites,
          message: response['message'] as String?,
          success: response['success'] ?? false,
          resultStatus: response['resultStatus'] as int?,
        );
      }
      
      throw Exception('Invalid response format');
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