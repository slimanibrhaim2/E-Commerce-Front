import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../repositories/base_repository.dart';
import '../models/cart_item.dart';

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
      final response = await apiClient.get(ApiEndpoints.cart);
      if (response is List) {
        return response.map((json) => CartItem.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  Future<CartItem> addToCart(String productId, int quantity) async {
    return handleApiCall(() async {
      final response = await apiClient.post(
        ApiEndpoints.cart,
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
      final response = await apiClient.post(
        '${ApiEndpoints.updateCartItem}$itemId',
        {
          'quantity': quantity,
        },
      );
      if (response is Map<String, dynamic>) {
        return CartItem.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  Future<void> removeFromCart(int itemId) async {
    await handleVoidApiCall(() async {
      await apiClient.post(
        '${ApiEndpoints.removeCartItem}$itemId',
        {},
      );
    });
  }

  Future<void> clearCart() async {
    await handleVoidApiCall(() async {
      await apiClient.post(
        ApiEndpoints.clearCart,
        {},
      );
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
} 