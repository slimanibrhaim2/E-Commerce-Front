import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/cart_item.dart';
import '../core/api/api_response.dart';

class CartRepository extends api.ApiRepositoryBase<CartItem> implements BaseRepository<CartItem> {
  CartRepository(super.apiClient);

  Future<void> handleVoidApiCall(Future<void> Function() apiCall) async {
    try {
      await apiCall();
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  Future<ApiResponse<List<CartItem>>> getCart({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.myCartItems}$queryParams';
      final response = await apiClient.get(endpoint);
      
      List<CartItem> cartItems = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          cartItems = innerData.map((json) => CartItem.fromJson(json)).toList();
        }
      } else if (response is List) {
        cartItems = response.map((json) => CartItem.fromJson(json)).toList();
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
      
      return ApiResponse<List<CartItem>>(
        data: cartItems,
        message: response['message'] as String?,
        success: response['success'] ?? false,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<CartItem> addToCart(String productId, int quantity) async {
    return handleApiCall(() async {
      final response = await apiClient.post(
        ApiEndpoints.addCartItem,
        {
          'productId': productId,
          'quantity': quantity,
        },
      );
      if (response is Map<String, dynamic>) {
        return CartItem.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  Future<ApiResponse<String>> updateCartItem(String itemId, int quantity) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.updateCartItem,
        {
          'itemId': itemId,
          'quantity': quantity,
        },
      );
      
      return ApiResponse<String>(
        data: response['data'] as String?,
        message: response['message'] as String?,
        success: response['success'] ?? false,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  @override
  Future<List<CartItem>> getAll() async {
    final response = await getCart();
    return response.data ?? [];
  }

  @override
  Future<CartItem?> getById(int id) {
    throw UnimplementedError('Not needed for cart');
  }

  @override
  Future<CartItem> create(CartItem item) {
    throw UnimplementedError('Use addToCart instead');
  }

  @override
  Future<CartItem> update(CartItem item) {
    throw UnimplementedError('Use updateCartItem instead');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Use removeFromCart instead');
  }

  Future<ApiResponse<String>> addItemToCart(String itemId, int quantity) async {
    final response = await apiClient.post(
      ApiEndpoints.addCartItem,
      {
        'itemId': itemId,
        'quantity': quantity,
      },
    );
    return ApiResponse<String>(
      data: response['data'] as String?,
      message: response['message'] as String?,
      success: response['success'] ?? false,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<ApiResponse<String>> removeFromCart(String itemId) async {
    try {
      final response = await apiClient.delete('${ApiEndpoints.removeCartItem}$itemId');
      
      return ApiResponse<String>(
        data: response['data'] as String?,
        message: response['message'] as String?,
        success: response['success'] ?? false,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }
} 