import '../core/api/api_base_repository.dart' as api;
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';
import '../models/follower.dart';
import '../models/following.dart';

class FollowRepository extends api.ApiRepositoryBase<void> {
  FollowRepository(super.apiClient);

  /// Follow a user
  /// POST /api/users/followers/{followingId}
  Future<ApiResponse<void>> followUser(String userId) async {
    try {
      print('Following user with ID: $userId');
      
      final endpoint = '${ApiEndpoints.userFollowers}/$userId';
      final response = await apiClient.post(endpoint, {});
      
      print('Follow response: $response');
      
      return ApiResponse<void>(
        data: null,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  /// DELETE /{followingId}
  Future<ApiResponse<void>> unfollowUser(String followingId) async {
    try {
      print('Unfollowing user with following ID: $followingId');
      
      final endpoint = '/$followingId';
      final response = await apiClient.delete(endpoint);
      
      print('Unfollow response: $response');
      
      return ApiResponse<void>(
        data: null,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Get users who follow me (my followers)
  /// GET /api/users/followers
  Future<ApiResponse<List<Follower>>> getMyFollowers({int pageNumber = 1, int pageSize = 10}) async {
    try {
      print('Getting my followers - page: $pageNumber, size: $pageSize');
      
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final fullUrl = '${ApiEndpoints.userFollowers}$queryParams';
      final response = await apiClient.get(fullUrl);
      
      print('My followers response: $response');
      
      List<Follower> followers = [];
      final outerData = response['data'];
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          followers = innerData.map((json) => Follower.fromJson(json)).toList();
        }
      }

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

      return ApiResponse<List<Follower>>(
        data: followers,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      print('Error getting my followers: $e');
      rethrow;
    }
  }

  /// Get users I follow (people I'm following)
  /// GET /api/users/followers/following
  Future<ApiResponse<List<Following>>> getMyFollowing({int pageNumber = 1, int pageSize = 10}) async {
    try {
      print('Getting users I follow - page: $pageNumber, size: $pageSize');
      
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final fullUrl = '${ApiEndpoints.userFollowing}$queryParams';
      final response = await apiClient.get(fullUrl);
      
      print('My following response: $response');
      
      List<Following> following = [];
      final outerData = response['data'];
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          following = innerData.map((json) => Following.fromJson(json)).toList();
        }
      }

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

      return ApiResponse<List<Following>>(
        data: following,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      print('Error getting users I follow: $e');
      rethrow;
    }
  }
} 