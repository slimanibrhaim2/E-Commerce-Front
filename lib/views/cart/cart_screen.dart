import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../../view_models/product_details_view_model.dart';
import '../../view_models/products_view_model.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart when screen opens if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      if (userViewModel.isLoggedIn) {
        context.read<CartViewModel>().loadCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'السلة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Selector2<CartViewModel, UserViewModel, Map<String, dynamic>>(
          selector: (context, cartViewModel, userViewModel) {
            return {
              'isLoggedIn': userViewModel.isLoggedIn,
              'isLoading': cartViewModel.isLoading,
              'error': cartViewModel.error,
              'cartItemsCount': cartViewModel.cartItems.length,
              'totalItems': cartViewModel.totalItems,
              'totalPrice': cartViewModel.totalPrice,
            };
          },
          builder: (context, data, child) {
            final isLoggedIn = data['isLoggedIn'] as bool;
            final isLoading = data['isLoading'] as bool;
            final error = data['error'] as String?;
            final cartItemsCount = data['cartItemsCount'] as int;
            final totalItems = data['totalItems'] as int;
            final totalPrice = data['totalPrice'] as double;

            // Check if user is logged in
            if (!isLoggedIn) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'يجب تسجيل الدخول لعرض السلة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isLoading) {
              return const Center(child: ModernLoader());
            }

            if (error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CartViewModel>().loadCart(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (cartItemsCount == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<CartViewModel>().loadCart(),
                    child: Selector<CartViewModel, List<CartItem>>(
                      selector: (context, cartViewModel) => cartViewModel.cartItems,
                      builder: (context, cartItems, child) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Selector<CartViewModel, CartItem?>(
                              selector: (context, cartViewModel) {
                                try {
                                  return cartViewModel.cartItems[index];
                                } catch (e) {
                                  return null;
                                }
                              },
                              builder: (context, item, child) {
                                if (item == null) return const SizedBox.shrink();
                                return CartItemWidget(
                                  item: item,
                                  index: index,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'عدد المنتجات:',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$totalItems منتج',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'المجموع الكلي:',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(0)} ل.س',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cartItemsCount > 0 ? () {
                              // TODO: Implement checkout
                            } : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: cartItemsCount > 0 ? Colors.blue : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              cartItemsCount > 0 ? 'إتمام الطلب' : 'السلة فارغة',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final int index;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(0)} ل.س',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () async {
                            if (item.quantity > 1) {
                              final result = await context.read<CartViewModel>().updateQuantity(
                                item.itemId,
                                item.quantity - 1,
                                context,
                              );
                              final message = result['message'] as String?;
                              final success = result['success'] as bool? ?? false;
                              if (message != null && context.mounted && message.isNotEmpty) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: message,
                                  type: success ? SnackBarType.success : SnackBarType.error,
                                );
                              }
                            } else {
                              final result = await context.read<CartViewModel>().removeFromCart(item.itemId, context);
                              final message = result['message'] as String?;
                              final success = result['success'] as bool? ?? false;
                              if (message != null && context.mounted && message.isNotEmpty) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: message,
                                  type: success ? SnackBarType.success : SnackBarType.error,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Selector<CartViewModel, int>(
                          selector: (context, cartViewModel) {
                            try {
                              final cartItem = cartViewModel.cartItems.firstWhere(
                                (cartItem) => cartItem.itemId == item.itemId,
                              );
                              return cartItem.quantity;
                            } catch (e) {
                              return item.quantity;
                            }
                          },
                          builder: (context, quantity, child) {
                            return Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () async {
                            final result = await context.read<CartViewModel>().updateQuantity(
                              item.itemId,
                              item.quantity + 1,
                              context,
                            );
                            final message = result['message'] as String?;
                            final success = result['success'] as bool? ?? false;
                            if (message != null && context.mounted && message.isNotEmpty) {
                              ModernSnackbar.show(
                                context: context,
                                message: message,
                                type: success ? SnackBarType.success : SnackBarType.error,
                              );
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final result = await context.read<CartViewModel>().removeFromCart(item.itemId, context);
                          final message = result['message'] as String?;
                          final success = result['success'] as bool? ?? false;
                          if (message != null && context.mounted && message.isNotEmpty) {
                            ModernSnackbar.show(
                              context: context,
                              message: message,
                              type: success ? SnackBarType.success : SnackBarType.error,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Selector<CartViewModel, double>(
                      selector: (context, cartViewModel) {
                        try {
                          final cartItem = cartViewModel.cartItems.firstWhere(
                            (cartItem) => cartItem.itemId == item.itemId,
                          );
                          return cartItem.totalPrice;
                        } catch (e) {
                          return item.totalPrice;
                        }
                      },
                      builder: (context, totalPrice, child) {
                        return Text(
                          'المجموع: ${totalPrice.toStringAsFixed(0)} ل.س',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 