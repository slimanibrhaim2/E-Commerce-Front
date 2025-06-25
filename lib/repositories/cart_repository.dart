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

  Future<List<CartItem>> getCart() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.myCart);
      if (response is List) {
        return response.map((json) => CartItem.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    });
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

  Future<CartItem> updateCartItem(int itemId, int quantity) async {
    return handleApiCall(() async {
      final response = await apiClient.put(
        ApiEndpoints.updateCartItem,
        {
          'itemId': itemId,
          'quantity': quantity,
        },
      );
      if (response is Map<String, dynamic>) {
        return CartItem.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  @override
  Future<List<CartItem>> getAll() async {
    return getCart();
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

  Future<void> removeFromCart(int itemId) async {
    await apiClient.delete('${ApiEndpoints.removeCartItem}$itemId');
  }
} 