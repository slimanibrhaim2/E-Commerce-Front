import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';
import '../models/review.dart';

class ReviewRepository {
  final ApiClient apiClient;

  ReviewRepository({required this.apiClient});

  Future<ApiResponse<Review>> createReview(Review review) async {
    try {
      final response = await apiClient.post(ApiEndpoints.reviews, review.toJson());
      
      if (response['success'] == true) {
        // Create review with returned ID
        final createdReview = review.copyWith(id: response['data'] as String?);
        return ApiResponse(
          data: createdReview,
          message: response['message'] as String?,
          success: response['success'] ?? true,
        );
      } else {
        return ApiResponse<Review>(
          data: null,
          message: response['message'] as String? ?? 'حدث خطأ في إنشاء المراجعة',
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<Review>(
        data: null,
        message: 'حدث خطأ في إنشاء المراجعة',
        success: false,
      );
    }
  }

  Future<ApiResponse<List<Review>>> getProviderReviews(
    String providerId, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final response = await apiClient.get('${ApiEndpoints.providerReviews}/$providerId$queryParams');
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final reviewsData = data['data'] as List<dynamic>;
        
        // Parse reviews
        final reviews = reviewsData
            .map((reviewJson) => Review.fromJson(reviewJson as Map<String, dynamic>))
            .toList();
        
        // Extract pagination metadata
        final paginationMetadata = {
          'totalCount': data['totalCount'] as int? ?? 0,
          'totalPages': data['totalPages'] as int? ?? 0,
          'pageNumber': data['pageNumber'] as int? ?? 1,
          'pageSize': data['pageSize'] as int? ?? 10,
          'hasNextPage': data['hasNextPage'] as bool? ?? false,
          'hasPreviousPage': data['hasPreviousPage'] as bool? ?? false,
        };
        
        return ApiResponse(
          data: reviews,
          message: response['message'] as String?,
          metadata: paginationMetadata,
        );
      } else {
        return ApiResponse(
          data: [],
          message: response['message'] as String? ?? 'حدث خطأ في جلب مراجعات البائع',
        );
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<Review>>> getMyReviews({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final response = await apiClient.get('${ApiEndpoints.myReviews}$queryParams');
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final reviewsData = data['data'] as List<dynamic>;
        
        // Parse reviews
        final reviews = reviewsData
            .map((reviewJson) => Review.fromJson(reviewJson as Map<String, dynamic>))
            .toList();
        
        // Extract pagination metadata
        final paginationMetadata = {
          'totalCount': data['totalCount'] as int? ?? 0,
          'totalPages': data['totalPages'] as int? ?? 0,
          'pageNumber': data['pageNumber'] as int? ?? 1,
          'pageSize': data['pageSize'] as int? ?? 10,
          'hasNextPage': data['hasNextPage'] as bool? ?? false,
          'hasPreviousPage': data['hasPreviousPage'] as bool? ?? false,
        };
        
        return ApiResponse(
          data: reviews,
          message: response['message'] as String?,
          metadata: paginationMetadata,
        );
      } else {
        return ApiResponse(
          data: [],
          message: response['message'] as String? ?? 'حدث خطأ في جلب المراجعات',
        );
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<List<Review>> _handleError(dynamic error) {
    return ApiResponse<List<Review>>(
      data: [],
      message: 'حدث خطأ في جلب المراجعات',
    );
  }
} 