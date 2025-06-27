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

  Future<ApiResponse<List<CartItem>>> getCart() async {
    try {
      final response = await apiClient.get(ApiEndpoints.myCartItems);
      
      List<CartItem> cartItems = [];
      
      // Handle wrapped response structure
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final cartItemsData = data['data'];
            if (cartItemsData is List) {
              cartItems = cartItemsData.map((json) => CartItem.fromJson(json)).toList();
            }
          }
          
          // Fallback: if data is directly a list
          if (data is List) {
            cartItems = data.map((json) => CartItem.fromJson(json)).toList();
          }
        }
        
        return ApiResponse<List<CartItem>>(
          data: cartItems,
          message: response['message'] as String?,
          success: response['success'] ?? false,
          resultStatus: response['resultStatus'] as int?,
        );
      }
      
      // Handle direct list response (fallback)
      if (response is List) {
        cartItems = response.map((json) => CartItem.fromJson(json)).toList();
        return ApiResponse<List<CartItem>>(
          data: cartItems,
          message: null,
          success: true,
          resultStatus: null,
        );
      }
      
      throw Exception('Invalid response format');
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