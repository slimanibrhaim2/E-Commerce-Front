import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';
import '../../../view_models/cart_view_model.dart';
import '../../../models/cart_item.dart';
import '../../../widgets/modern_snackbar.dart';

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
                        context.read<CartViewModel>().apiClient.getMediaUrl(item.imageUrl!),
                        fit: BoxFit.contain,
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
                    '${(item.price ?? 0).toStringAsFixed(0)} ل.س',
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
                                color: AppColors.primary,
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