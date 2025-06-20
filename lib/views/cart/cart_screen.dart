import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/cart_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../main_navigation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
            Consumer<CartViewModel>(
              builder: (context, cart, child) {
                if (cart.cartItems.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          title: const Text(
                            'تفريغ السلة',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          content: const Text(
                            'هل أنت متأكد من رغبتك في تفريغ السلة؟',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final message = await cart.clearCart(context);
                                if (message != null && context.mounted) {
                                  ModernSnackbar.show(
                                    context: context,
                                    message: message,
                                    type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                  );
                                }
                              },
                              child: const Text(
                                'تفريغ',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<CartViewModel>(
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
                        if (message != null && context.mounted) {
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                // child: Image.network(
                                //   item.product.imageUrl,
                                //   width: 80,
                                //   height: 80,
                                //   fit: BoxFit.cover,
                                //   errorBuilder: (context, error, stackTrace) {
                                //     return Container(
                                //       width: 80,
                                //       height: 80,
                                //       color: Colors.grey[200],
                                //       child: const Icon(
                                //         Icons.image_not_supported,
                                //         color: Colors.grey,
                                //       ),
                                //     );
                                //   },
                                // ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.product.price} ل.س',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () async {
                                      if (item.quantity > 1) {
                                        final message = await cart.updateQuantity(
                                          item.id,
                                          item.quantity - 1,
                                          context,
                                        );
                                        if (message != null && context.mounted) {
                                          ModernSnackbar.show(
                                            context: context,
                                            message: message,
                                            type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                          );
                                        }
                                      } else {
                                        final message = await cart.removeFromCart(item.id, context);
                                        if (message != null && context.mounted) {
                                          ModernSnackbar.show(
                                            context: context,
                                            message: message,
                                            type: cart.error != null ? SnackBarType.error : SnackBarType.success,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      final message = await cart.updateQuantity(
                                        item.id,
                                        item.quantity + 1,
                                        context,
                                      );
                                      if (message != null && context.mounted) {
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
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
                            const Text(
                              'المجموع:',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${cart.totalPrice} ل.س',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement checkout
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text(
                              'إتمام الطلب',
                              style: TextStyle(
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