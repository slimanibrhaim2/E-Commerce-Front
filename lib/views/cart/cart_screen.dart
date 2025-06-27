import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../main_navigation_screen.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../../view_models/product_details_view_model.dart';
import '../../view_models/products_view_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Only refresh cart if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserViewModel>();
      if (user.isLoggedIn) {
        _refreshCart();
      }
    });
  }

  Future<void> _refreshCart() async {
    final cartViewModel = context.read<CartViewModel>();
    final message = await cartViewModel.loadCart();
    if (message != null && mounted) {
      ModernSnackbar.show(
        context: context,
        message: message,
        type: SnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'سلة التسوق',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer2<UserViewModel, CartViewModel>(
              builder: (context, user, cart, child) {
                if (user.isLoggedIn && cart.cartItems.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Consumer<UserViewModel>(
              builder: (context, user, child) {
                if (!user.isLoggedIn) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshCart,
                );
              },
            ),
          ],
        ),
        body: Consumer<UserViewModel>(
          builder: (context, user, child) {
            if (!user.isLoggedIn) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'الرجاء تسجيل الدخول لعرض سلة التسوق',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Consumer<CartViewModel>(
              builder: (context, cart, child) {
                if (cart.isLoading) {
                  return const Center(child: ModernLoader());
                }
                if (cart.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cart.error!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final message = await cart.loadCart();
                            if (message != null && context.mounted && message.isNotEmpty) {
                              ModernSnackbar.show(
                                context: context,
                                message: message,
                                type: SnackBarType.error,
                              );
                            }
                          },
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (cart.cartItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'سلة التسوق فارغة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cart.cartItems[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                    create: (context) => ProductDetailsViewModel(
                                      context.read<ProductsViewModel>().repository,
                                    ),
                                    child: ProductDetailScreen(productId: item.itemId),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                item.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
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
                                                      final message = await cart.updateQuantity(
                                                        item.itemId,
                                                        item.quantity - 1,
                                                        context,
                                                      );
                                                      if (message != null && context.mounted && message.isNotEmpty) {
                                                        ModernSnackbar.show(
                                                          context: context,
                                                          message: message,
                                                          type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                                        );
                                                      }
                                                    } else {
                                                      final message = await cart.removeFromCart(item.itemId, context);
                                                      if (message != null && context.mounted && message.isNotEmpty) {
                                                        ModernSnackbar.show(
                                                          context: context,
                                                          message: message,
                                                          type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.pink,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(Icons.add, size: 18),
                                                  onPressed: () async {
                                                    final message = await cart.updateQuantity(
                                                      item.itemId,
                                                      item.quantity + 1,
                                                      context,
                                                    );
                                                    if (message != null && context.mounted && message.isNotEmpty) {
                                                      ModernSnackbar.show(
                                                        context: context,
                                                        message: message,
                                                        type: cart.error != null ? SnackBarType.error : SnackBarType.success,
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
                                                  final message = await cart.removeFromCart(item.itemId, context);
                                                  if (message != null && context.mounted && message.isNotEmpty) {
                                                    ModernSnackbar.show(
                                                      context: context,
                                                      message: message,
                                                      type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Center(
                                            child: Text(
                                              'المجموع: ${item.totalPrice.toStringAsFixed(0)} ل.س',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
                                      '${cart.totalItems} منتج',
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
                                      '${cart.totalPrice.toStringAsFixed(0)} ل.س',
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
                                onPressed: cart.cartItems.isNotEmpty ? () {
                                  // TODO: Implement checkout
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: cart.cartItems.isNotEmpty ? Colors.blue : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  cart.cartItems.isNotEmpty ? 'إتمام الطلب' : 'السلة فارغة',
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
            );
          },
        ),
      ),
    );
  }
} 